{ config, lib, ... }:
let
  inherit (config) homelab;
  service = "bazarr";
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
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      inherit (homelab) user group;
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString config.services.${service}.listenPort}
      '';
    };
  };
}
