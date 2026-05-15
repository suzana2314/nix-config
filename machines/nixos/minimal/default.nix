{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
    ./disks.nix
    ../../common/core
    ../../common/options/systemd-bootloader
    ../../common/options/openssh
    ../../common/users/tmp
  ];

  networking.hostName = "minimal";
  networking.firewall.enable = true;

  system.stateVersion = "25.11";
}
