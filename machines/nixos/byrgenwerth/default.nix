{
  inputs,
  pkgs,
  ...
}:
let
  networkCfg = inputs.nix-secrets.networking;
  hostCfg = networkCfg.subnets.default.hosts.byrgenwerth;
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

  hardware.graphics.extraPackages = with pkgs; [
    vaapiIntel
    intel-media-driver
  ];

  networking = {
    hostName = hostCfg.name;
    enableIPv6 = false;
    useDHCP = false;
    interfaces.enp0s31f6.ipv4.addresses = [
      {
        address = hostCfg.ip;
        inherit (networkCfg.subnets.default) prefixLength;
      }
    ];
    defaultGateway = networkCfg.subnets.default.gateway;
    nameservers = hostCfg.dns;
    firewall.enable = true;
  };

  system.stateVersion = "24.05";
}
