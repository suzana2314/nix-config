{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "readeck";
  cfg = homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 9312;
    };
    environmentFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to environment file, used to set the secret key by using READECK_SECRET_KEY";
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      environmentFile = cfg.environmentFile;
      settings = {
        main = {
          log_level = "info";
        };
        server = {
          port = cfg.port;
        };
      };
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
