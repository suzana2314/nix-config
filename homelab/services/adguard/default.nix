{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "adguardhome";
  cfg = homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "dns.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      description = "Web dashboard port";
      default = 2314;
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      inherit (cfg) port;
      host = "127.0.0.1";
      settings = {
        http = {
          address = "127.0.0.1:${toString cfg.port}";
        };
      };
    };

    networking.firewall = {
      allowedUDPPorts = [ 53 ]; # open dns port
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
