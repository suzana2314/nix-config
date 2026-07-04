{ inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
    ./disko.nix
    ./homelab
    ../../common/core
    ../../common/options/systemd-bootloader
    ../../common/options/mdns
    ../../common/options/openssh
    ../../common/users/suz
  ];

  networking = {
    hostName = "yahargul";
    enableIPv6 = false;
    useDHCP = true;
    firewall.enable = true;
  };

  system.stateVersion = "25.05";
}
