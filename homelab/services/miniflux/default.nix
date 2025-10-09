{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "miniflux";
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
      default = "${service}.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.str;
      default = "8945";
    };
    environmentFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to environment file";
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      config = {
        LISTEN_ADDR = "127.0.0.1:${cfg.port}";
      };
      adminCredentialsFile = cfg.environmentFile;
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${cfg.port}
      '';
    };
  };
}
