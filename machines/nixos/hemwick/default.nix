{ inputs, ... }:
let
  networkCfg = inputs.nix-secrets.networking;
  hostCfg = networkCfg.subnets.default.hosts.hemwick;
in
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

  networking = {
    hostName = hostCfg.name;
    enableIPv6 = false;
    useDHCP = false;
    interfaces.enp3s0.ipv4.addresses = [
      {
        address = hostCfg.ip;
        inherit (networkCfg.subnets.default) prefixLength;
      }
    ];
    defaultGateway = networkCfg.subnets.default.gateway;
    nameservers = hostCfg.dns;
    firewall.enable = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    reflector = true;
  };

  system.stateVersion = "24.05";
}
