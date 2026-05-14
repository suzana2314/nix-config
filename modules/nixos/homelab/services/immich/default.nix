{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "immich";
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
      default = 2283;
    };
    monitoredServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "immich-server"
        "redis-immich"
      ];
    };
    mediaDir = lib.mkOption {
      type = lib.types.path;
      default = "/storage/immich";
    };
    accelerationDevices = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      description = "Path to the accelarator device";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "d ${cfg.mediaDir} 0775 immich immich - -" ];
    services.${service} = {
      enable = true;
      port = cfg.port;
      openFirewall = !homelab.services.reverseProxy.enable;
      mediaLocation = "${cfg.mediaDir}";
      inherit (cfg) accelerationDevices;
      machine-learning.enable = false;
      settings.server = {
        externalDomain = "https://${cfg.url}";
      };
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://${config.services.immich.host}:${toString cfg.port}
      '';
    };

  };
}
