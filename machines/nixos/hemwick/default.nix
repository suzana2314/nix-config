{ inputs, config, ... }:
let
  networkCfg = inputs.nix-secrets.networking;
  hostCfg = networkCfg.subnets.default.hosts.hemwick;
  sopsFile = "${builtins.toString inputs.nix-secrets}/sops/${config.networking.hostName}.yaml";
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
    ../../common/options/ssh
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

    # TODO homeassistant might start acting weird if I enable the firewall, need to check what ports need to be open
    firewall.enable = false;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    reflector = true;
  };

  users.users.suz = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILk1CVabYzs/tTMEkho+MlbiLW+wfD2MQo5RDgYBLO/W suz@master"
    ];
  };

  autoUpgrade = {
    enable = true;
    user = config.users.users.suz.name;
    telegram = {
      enable = true;
      credentialsFile = config.sops.secrets."telegram/auto-update".path;
    };
  };

  sops.secrets = {
    "telegram/auto-update" = {
      inherit sopsFile;
      owner = config.users.users.suz.name;
      mode = "0440";
    };
  };

  system.stateVersion = "24.05";
}
