{ inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
    ./disko.nix
    ./homelab
    ../../../homelab
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
    nameservers = [
      "9.9.9.9"
      "149.112.112.112"
    ];
  };

  system.stateVersion = "25.05";
}
