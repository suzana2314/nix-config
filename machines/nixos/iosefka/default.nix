{ lib, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    ./homelab
    ../../common/core
    ../../common/users/suz
    ../../common/options/openssh
    ../../common/options/mdns
  ];

  networking.hostName = "iosefka";

  nixpkgs.hostPlatform = "aarch64-linux";
  hardware.enableRedistributableFirmware = true;
  boot.supportedFilesystems.zfs = lib.mkForce false;
  sdImage.compressImage = false;

  system.stateVersion = "26.05";
}
