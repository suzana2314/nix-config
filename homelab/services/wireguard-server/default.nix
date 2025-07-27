{
  lib,
  config,
  ...
}:
let
  inherit (config) homelab;
  service = "wireguard-server";
  cfg = homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption "Enable ${service}";

    networkInterface = lib.mkOption {
      type = lib.types.str;
      default = "eth0";
      description = "External network interface for NAT";
    };

    wireguardInterface = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
      description = "WireGuard interface name";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 51820;
      description = "WireGuard listen port";
    };

    serverIp = lib.mkOption {
      type = lib.types.str;
      default = "10.100.0.1/24";
      description = "Server IP address and subnet";
    };

    subnet = lib.mkOption {
      type = lib.types.str;
      default = "10.100.0.0/24";
      description = "WireGuard VPN subnet";
    };

    privateKeyFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the WireGuard private key file";
    };

    peers = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = "List of WireGuard peers";
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      nat = {
        enable = true;
        externalInterface = cfg.networkInterface;
        internalInterfaces = [ cfg.wireguardInterface ];
      };

      firewall = {
        allowedUDPPorts = [ cfg.port ];
      };

      wireguard.interfaces = {
        ${cfg.wireguardInterface} = {
          inherit (cfg) privateKeyFile peers;
          ips = [ cfg.serverIp ];
          listenPort = cfg.port;
        };
      };
    };
  };
}
