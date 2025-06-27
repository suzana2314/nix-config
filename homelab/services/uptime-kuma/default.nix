{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "uptime-kuma";
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
      default = "kuma.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.str;
      default = "3895";
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      appriseSupport = true;
      settings = {
        PORT = cfg.port;
      };
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${cfg.port}
      '';
    };
  };
}
