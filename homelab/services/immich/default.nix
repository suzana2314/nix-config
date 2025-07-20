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
    mediaDir = lib.mkOption {
      type = lib.types.path;
      default = "/storage/immich";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "d ${cfg.mediaDir} 0775 immich immich - -" ];

    services.immich = {
      enable = true;
      port = 2283;
      mediaLocation = "${cfg.mediaDir}";
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://${config.services.immich.host}:${toString config.services.immich.port}
      '';
    };

  };
}
