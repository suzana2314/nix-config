# https://github.com/Misterio77/nix-config/blob/main/hosts/common/optional/ephemeral-btrfs.nix
# https://saylesss88.github.io/installation/enc/encrypted_impermanence.html
{
  inputs,
  lib,
  config,
  ...
}:
let
  root = config.fileSystems."/";

  wipeScript = ''
    mkdir /tmp -p
    MNTPOINT=$(mktemp -d)
    (
      mount -t btrfs -o subvol=/ ${root.device} "$MNTPOINT"
      trap 'umount "$MNTPOINT"' EXIT

      echo "Creating needed directories"
      mkdir -p "$MNTPOINT"/persist/var/{log,lib/{nixos,systemd}}
      if [ -e "$MNTPOINT/dont-wipe" ]; then
        echo "Skipping wipe"
      else
        echo "Cleaning root subvolume"
        btrfs subvolume delete -R "$MNTPOINT/root"
        echo "Restoring blank subvolume"
        btrfs subvolume snapshot "$MNTPOINT/root-blank" "$MNTPOINT/root"
      fi
    )
  '';

  # Convert a device path to a systemd .device
  toSystemdDevice =
    device:
    lib.concatStringsSep "-" (
      lib.tail (map (lib.replaceString "-" "\\x2d") (lib.splitString "/" device))
    )
    + ".device";

  phase1Systemd = config.boot.initrd.systemd.enable;
in
{

  imports = [ inputs.impermanence.nixosModules.impermanence ];

  boot.initrd = {
    supportedFilesystems = [ "btrfs" ];
    postDeviceCommands = lib.mkIf (!phase1Systemd) (lib.mkBefore wipeScript);
    systemd.services.restore-root = lib.mkIf phase1Systemd {
      description = "Rollback btrfs rootfs";
      wantedBy = [ "initrd.target" ];
      requires = [ (toSystemdDevice root.device) ];
      after = [ (toSystemdDevice root.device) ];
      before = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = wipeScript;
    };
  };

  fileSystems."/persist".neededForBoot = lib.mkDefault true;

  environment.persistence = {
    "/persist" = {
      directories = [
        "/etc"
        "/etc/NetworkManager/system-connections"
        "/var/lib/fprint"
        "/var/lib/systemd"
        "/var/lib/nixos"
        "/var/log"
        "/srv"
      ];
    };
  };

  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';

}
