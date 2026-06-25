import ipaddress
import shutil
import subprocess
import sys
from pathlib import Path

MACHINES_CFG_DIR = Path("machines/nixos")
DEFAULT_HOST = "iso.local"
REQUIRED_TOOLS = ("ping", "ssh-keyscan", "ssh-to-age", "nix")
TOTAL_STEPS = 5

# colours and fmt
RESET = "\033[0m"
BOLD = "\033[1m"
DIM = "\033[2m"
RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
MAGENTA = "\033[35m"
CYAN = "\033[36m"


def info(msg: str) -> None:
    print(f"{BLUE}{BOLD}[I]{RESET}  {msg}")


def success(msg: str) -> None:
    print(f"{GREEN}{BOLD}[S]{RESET}  {msg}")


def warn(msg: str) -> None:
    print(f"{YELLOW}{BOLD}[W]{RESET}  {msg}")


def error(msg: str) -> None:
    print(f"{RED}{BOLD}[E]{RESET}  {msg}")


def step(n: int, msg: str) -> None:
    print(f"\n{CYAN}{BOLD}[{n}/{TOTAL_STEPS}]{RESET} {BOLD}{msg}{RESET}")


def ask(prompt: str) -> str:
    return input(f"{MAGENTA}{BOLD}>{RESET} {prompt}").strip()


def confirm(prompt: str) -> bool:
    return ask(f"{prompt} {DIM}[y/N]{RESET} ").lower() in ("y", "yes")


def kill(msg: str):
    error(msg)
    sys.exit(1)


def banner() -> None:
    line = "─" * 32
    print(f"{CYAN}╭{line}╮{RESET}")
    print(f"{CYAN}│{RESET}  {BOLD}NixOS Bootstrapper{RESET}{' ' * 12}{CYAN}│{RESET}")
    print(
        f"{CYAN}│{RESET}  {DIM}powered by nixos-anywhere :){RESET}"
        f"{' ' * 2}{CYAN}│{RESET}"
    )
    print(f"{CYAN}╰{line}╯{RESET}")


def check_required_tools() -> None:
    missing = [tool for tool in REQUIRED_TOOLS if shutil.which(tool) is None]
    if missing:
        kill(f"Missing required tool(s): {', '.join(missing)}")


def prompt_hostname() -> str:
    while True:
        hostname = ask("Enter the hostname: ")
        if not hostname:
            warn("Hostname cannot be empty!")
            continue
        if (MACHINES_CFG_DIR / hostname).exists():
            return hostname
        error(f"No machine config found at {MACHINES_CFG_DIR / hostname}")


def ping_host(host: str) -> bool:
    cmd = ["ping", "-c", "1", "-W", "2", host]
    try:
        resp = subprocess.run(
            cmd,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=5,
        )
        return resp.returncode == 0
    except (subprocess.TimeoutExpired, OSError):
        return False


def prompt_ip_address() -> str:
    while True:
        ip = ask("Enter remote machine IP address: ")
        try:
            ipaddress.ip_address(ip)
        except ValueError:
            error("Invalid IP address. Please try again!")
            continue
        if not ping_host(ip):
            warn(f"{ip} is not reachable. Please try again!")
            continue
        return ip


def get_age_key(host: str) -> str | None:
    try:
        ssh_scan_out = subprocess.check_output(
            ["ssh-keyscan", "-t", "ed25519", host],
            text=True,
            stderr=subprocess.DEVNULL,
        )
        if not ssh_scan_out.strip():
            return None
        age_out = subprocess.check_output(["ssh-to-age"], input=ssh_scan_out, text=True)
        return age_out.strip() or None
    except subprocess.CalledProcessError:
        return None


def update_flake() -> bool:
    try:
        return subprocess.run(["nix", "flake", "update"]).returncode == 0
    except OSError:
        return False


def run_nix_anywhere(host: str, hostname: str) -> bool:
    hardwareonfig_path = MACHINES_CFG_DIR / hostname / "hardware-configuration.nix"
    cmd = [
        "nix",
        "run",
        "github:nix-community/nixos-anywhere",
        "--",
        "--copy-host-keys",
        "--generate-hardware-config",
        "nixos-generate-config",
        str(hardwareonfig_path),
        "--flake",
        f".#{hostname}",
        "--target-host",
        f"root@{host}",
    ]
    try:
        subprocess.run(cmd, check=True)
        return True
    except subprocess.CalledProcessError:
        return False


def main():
    banner()
    check_required_tools()
    info(
        "Make sure the ISO host is up and running, and don't forget to connect it to the LAN ;)"
    )

    step(1, "Select machine configuration")
    hostname = prompt_hostname()
    success(f"Using config: {BOLD}{hostname}{RESET}")

    step(2, "Locate target host")
    host = DEFAULT_HOST
    if ping_host(host):
        success(f"Reached default host: {BOLD}{host}{RESET}")
    else:
        warn(f"Could not reach {host}, falling back to manual entry...")
        host = prompt_ip_address()
        success(f"Reached host: {BOLD}{host}{RESET}")

    step(3, "Derive age key & configure sops")
    age_key = get_age_key(host)
    if not age_key:
        kill("Failed to derive the age key from the host's SSH key")
    success("Derived age key:")
    print(f"   {GREEN}{age_key}{RESET}\n")
    info(
        "Add this key to your .sops.yaml, then rekey the secrets and push "
        "them to the remote"
    )
    ask(f"{DIM}Press Enter once sops is configured...{RESET}")

    step(4, "Update flake inputs")
    if not update_flake():
        kill("Failed to update the flake")
    success("Flake updated")

    step(5, "Deploy NixOS")
    warn(
        f"This will {BOLD}erase{RESET} the target disk on "
        f"{BOLD}root@{host}{RESET} and install {BOLD}{hostname}{RESET}."
    )
    if not confirm("Proceed with deployment?"):
        info("Deployment cancelled")
        sys.exit(0)
    if not run_nix_anywhere(host, hostname):
        kill("Deployment failed")

    print()
    success(f"{BOLD}{hostname}{RESET} was installed successfully :)")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print()
        error("Aborted")
        sys.exit(130)
