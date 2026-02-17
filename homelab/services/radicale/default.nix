{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "radicale";
  cfg = homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}/collections";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "dav.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.str;
      default = "5232";
    };
    passwdFile = lib.mkOption {
      type = lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    services.radicale = {
      enable = true;
      settings = {
        server = {
          hosts = [
            "127.0.0.1:${cfg.port}"
          ];
        };
        storage = {
          filesystem_folder = cfg.configDir;
        };

        auth = {
          type = "htpasswd";
          htpasswd_filename = cfg.passwdFile;
          htpasswd_encryption = "autodetect";
        };
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
