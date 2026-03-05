{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "vaultwarden";
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
      default = "vault.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8222;
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      config = {
        DOMAIN = "https://${cfg.url}";
        SIGNUPS_ALLOWED = false;
        EXTENDED_LOGGING = true;
        LOG_LEVEL = "warn";
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = cfg.port;
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
