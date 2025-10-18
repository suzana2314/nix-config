{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "scanservjs";
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
      default = "scan.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.str;
      default = "8432";
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      settings = {
        port = lib.strings.toInt cfg.port;
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
