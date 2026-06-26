import ipaddress
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

MACHINES_CFG_DIR = Path("machines/nixos")
SECRETS_HOSTS_DIR = Path("/tmp/nixos-bootstrap/hosts")
SSH_KEY_NAME = "ssh_host_ed25519_key"
DEFAULT_HOST = "iso.local"
DEFAULT_PERSIST = "/persist"
REQUIRED_TOOLS = ("ping", "ssh-keyscan", "ssh-keygen", "ssh-to-age", "nix")
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


def warn(msg: str) -> None:
    print(f"{YELLOW}{BOLD}[W]{RESET}  {msg}")


def error(msg: str) -> None:
    print(f"{RED}{BOLD}[E]{RESET}  {msg}")


def step(n: int, msg: str) -> None:
    print(f"\n{CYAN}{BOLD}[{n}/{TOTAL_STEPS}]{RESET} {BOLD}{msg}{RESET}")


def ask(prompt: str) -> str:
    return input(f"{MAGENTA}{BOLD}>{RESET} {prompt}").strip()


def ask_default(prompt: str, default: str) -> str:
    resp = ask(f"{prompt} {DIM}[{default}]{RESET} ")
    return resp or default


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


def ensure_host_keys(hostname: str) -> Path:
    key_dir = SECRETS_HOSTS_DIR / hostname
    priv = key_dir / SSH_KEY_NAME
    pub = key_dir / f"{SSH_KEY_NAME}.pub"

    if priv.exists() and pub.exists():
        info(f"Found pre-generated host keys in {BOLD}{key_dir}{RESET}")
        return priv

    warn(f"No pre-generated host keys found in {key_dir}")
    if not confirm("Generate a new ed25519 host key pair?"):
        kill("Impermanent hosts need pre-generated SSH host keys to proceed")

    key_dir.mkdir(parents=True, exist_ok=True)
    try:
        subprocess.run(
            ["ssh-keygen", "-t", "ed25519", "-N", "", "-C", hostname, "-f", str(priv)],
            check=True,
            stdout=subprocess.DEVNULL,
        )
    except (subprocess.CalledProcessError, OSError):
        kill("Failed to generate host keys")
    info(f"Generated host keys in {BOLD}{key_dir}{RESET}")
    return priv


def age_key_from_pub(pub_key_path: Path) -> str | None:
    try:
        content = pub_key_path.read_text()
        age_out = subprocess.check_output(
            ["ssh-to-age"], input=content, text=True, stderr=subprocess.DEVNULL
        )
        return age_out.strip() or None
    except (subprocess.CalledProcessError, OSError):
        return None


def build_extra_files(priv_key: Path, persist: str) -> str:
    pub_key = priv_key.parent / f"{priv_key.name}.pub"
    tmp_root = Path(tempfile.mkdtemp(prefix="nixos-anywhere-extra-"))
    ssh_dir = tmp_root.joinpath(persist.lstrip("/"), "etc", "ssh")
    ssh_dir.mkdir(parents=True, exist_ok=True)

    dst_priv = ssh_dir / priv_key.name
    dst_pub = ssh_dir / pub_key.name
    shutil.copy2(priv_key, dst_priv)
    shutil.copy2(pub_key, dst_pub)
    dst_priv.chmod(0o600)
    dst_pub.chmod(0o644)
    return str(tmp_root)


def run_update_flake() -> bool:
    try:
        return subprocess.run(["nix", "flake", "update"]).returncode == 0
    except OSError:
        return False


def run_nix_anywhere(host: str, hostname: str, extra_files: str | None = None) -> bool:
    hardwareonfig_path = MACHINES_CFG_DIR / hostname / "hardware-configuration.nix"
    cmd = [
        "nix",
        "run",
        "github:nix-community/nixos-anywhere",
        "--",
        "--generate-hardware-config",
        "nixos-generate-config",
        str(hardwareonfig_path),
        "--flake",
        f".#{hostname}",
        "--target-host",
        f"root@{host}",
    ]
    if extra_files:
        cmd += ["--extra-files", extra_files]
    else:
        cmd += ["--copy-host-keys"]
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
    info(f"Using config: {BOLD}{hostname}{RESET}")

    impermanent = confirm("Does this host use impermanence?")
    persist = DEFAULT_PERSIST
    if impermanent:
        persist = ask_default("Persist location:", DEFAULT_PERSIST)
        info(
            "Pre-generated SSH host keys will be persisted under "
            f"{BOLD}{persist.rstrip('/')}/etc/ssh{RESET} via --extra-files"
        )

    step(2, "Locate target host")
    host = DEFAULT_HOST
    if ping_host(host):
        info(f"Reached default host: {BOLD}{host}{RESET}")
    else:
        warn(f"Could not reach {host}, falling back to manual entry...")
        host = prompt_ip_address()
        info(f"Reached host: {BOLD}{host}{RESET}")

    step(3, "Derive age key & configure sops")
    priv_key: Path = Path()
    if impermanent:
        priv_key = ensure_host_keys(hostname)
        pub_key = priv_key.parent / f"{priv_key.name}.pub"
        age_key = age_key_from_pub(pub_key)
    else:
        age_key = get_age_key(host)
    if not age_key:
        kill("Failed to derive the age key")
    info("Derived age key:")
    print(f"   {GREEN}{age_key}{RESET}\n")
    info(
        "Add this key to your .sops.yaml, then rekey the secrets and push "
        "them to the remote"
    )
    ask(f"{DIM}Press Enter once sops is configured...{RESET}")

    step(4, "Update flake inputs")
    if not run_update_flake():
        kill("Failed to update the flake")
    info("Flake updated")

    step(5, "Deploy NixOS")
    warn(
        f"This will {BOLD}erase{RESET} the target disk on "
        f"{BOLD}root@{host}{RESET} and install {BOLD}{hostname}{RESET}."
    )
    if not confirm("Proceed with deployment?"):
        info("Deployment cancelled")
        sys.exit(0)

    extra_files = None
    if impermanent:
        extra_files = build_extra_files(priv_key, persist)
    try:
        deployed = run_nix_anywhere(host, hostname, extra_files)
    finally:
        if extra_files:
            shutil.rmtree(extra_files, ignore_errors=True)
    if not deployed:
        kill("Deployment failed")

    print()
    info(f"{BOLD}{hostname}{RESET} was installed successfully :)")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print()
        error("Aborted")
        sys.exit(130)
