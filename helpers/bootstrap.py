import subprocess
from pathlib import Path
import ipaddress

MACHINES_CFG_DIR = Path("machines/nixos")


def prompt_hostname() -> str:
    while True:
        hostname = input("Enter the hostname: ").strip()
        path = MACHINES_CFG_DIR / hostname
        if path.exists():
            return hostname
        print("Machine config does not exist! Input a valid hostname")


# this will be a fallback
def prompt_ip_address() -> str:
    while True:
        ip = input("Enter remote machine ip address: ").strip()
        try:
            ipaddress.ip_address(ip)
            if not ping_host(ip):
                print("Address not reachable! Input a valid address")
                continue
            return ip
        except ValueError:
            print("Invalid ipv4 ip address! Input a valid address")


def ping_host(host: str) -> bool:
    cmd = ["ping", "-c", "1", host]

    resp = subprocess.call(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)

    return resp == 0


def get_age_key(host: str) -> str | None:
    scan_cmd = ["ssh-keyscan", "-t", "ed25519", host]
    try:
        ssh_scan_out = subprocess.check_output(
            scan_cmd, text=True, stderr=subprocess.DEVNULL
        )

        if not ssh_scan_out.strip():
            return None

        age_cmd = ["ssh-to-age"]
        age_out = subprocess.check_output(age_cmd, input=ssh_scan_out, text=True)

        return age_out.strip()

    except subprocess.CalledProcessError:
        return None


def update_flake() -> bool:
    cmd = ["nix", "flake", "update"]
    try:
        resp = subprocess.call(cmd, stderr=subprocess.DEVNULL)
        return resp == 0
    except subprocess.CalledProcessError:
        return False


def run_nix_anywhere(host: str, hostname: str) -> bool:
    host_dir = MACHINES_CFG_DIR / hostname
    hardware_config_path = host_dir / "hardware-configuration.nix"
    try:
        cmd = [
            "nix",
            "run",
            "github:nix-community/nixos-anywhere",
            "--",
            "--copy-host-keys",
            "--generate-hardware-config",
            "nixos-generate-config",
            str(hardware_config_path),
            "--flake",
            f".#{hostname}",
            "--target-host",
            f"root@{host}",
        ]

        resp = subprocess.run(cmd, check=True)

        return resp == 0
    except subprocess.CalledProcessError:
        return False


def main():
    print(
        "Make sure iso host is up and running, and don't forget to connect it to the LAN ;)"
    )
    hostname = prompt_hostname()
    host = "iso.local"

    if not ping_host(host):
        print("Could not find iso host!")
        host = prompt_ip_address()

    age_key = get_age_key(host)

    if age_key:
        print(f"Got age key: {age_key}")
    else:
        print("There was an error getting the age key")
        return

    print("""
          Copy the age key and add it to your .sops.yaml file
          Then rekey the secrets and push them to the remote
          """)
    input("Press Enter to continue...")
    print("Updating flake...")
    if update_flake():
        print("Success")
    else:
        print("Oops")
        return
    if run_nix_anywhere(host, hostname):
        print("Success")
    else:
        print("Oops")
        return


if __name__ == "__main__":
    main()
