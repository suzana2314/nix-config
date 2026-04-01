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
    ../../common/options/openssh
    ../../common/users/suz
  ];

  networking.hostName = "hemwick";

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    reflector = true;
  };

  system.stateVersion = "24.05";
}
