{ inputs, ... }:
let
  networkCfg = inputs.nix-secrets.networking;
  hostCfg = networkCfg.subnets.default.hosts.bunker;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
    ./disko.nix
    ../../common/core
    ../../common/options/systemd-bootloader
    ../../common/options/ssh
    ../../common/options/audio
    ../../common/options/wireless
    ../../common/options/printing
    ../../common/options/x
    ../../common/users/suz
    ../../common/users/zez
  ];

  networking = {
    hostName = hostCfg.name;
    enableIPv6 = false;
    useDHCP = false;
    interfaces.eno1.ipv4.addresses = [
      {
        address = hostCfg.ip;
        inherit (networkCfg.subnets.default) prefixLength;
      }
    ];
    defaultGateway = networkCfg.subnets.default.gateway;
    nameservers = hostCfg.dns;
    firewall.enable = true;
  };

  users.users.suz = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIImxSnO9NA+4Mg2t55gOGi7iwbPkVhVdy+qP5HjTtLQY suz@master"
    ];
  };

  system.stateVersion = "25.05";
}
