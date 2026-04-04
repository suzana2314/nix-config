{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "esphome";
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
    environmentFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to environment file containing USERNAME and PASSWORD";
      example = ''
        USERNAME=john_doe
        PASSWORD=hunter2
      '';
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 6052;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.avahi.enable;
        message = "${service} requires mDNS to work properly!";
      }
    ];
    services.${service} = {
      enable = true;
      usePing = false;
      allowedDevices = [ ];
      openFirewall = !homelab.services.reverseProxy.enable;
      address = if homelab.services.reverseProxy.enable then "0.0.0.0" else "localhost";
      port = cfg.port;
    };
    systemd.services.${service}.serviceConfig = {
      EnvironmentFile = [ cfg.environmentFile ];
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };

  };
}
