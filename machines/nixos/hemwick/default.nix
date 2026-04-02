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

  networking.hostName = "hemwick";

  system.stateVersion = "24.05";
}
