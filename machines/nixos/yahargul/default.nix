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
    ../../common/options/ssh
    ../../common/users/brb
  ];

  networking = {
    hostName = "yahargul";
    enableIPv6 = false;
    useDHCP = true;
    firewall.enable = false;
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    reflector = true;
  };

  users.users.brb = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBwP5RHIg3Ad/MRmWNXEXDNBgX6dqlED9e+TDPTEcc9Q brb@yahargul"
    ];
  };

  system.stateVersion = "25.05";
}
