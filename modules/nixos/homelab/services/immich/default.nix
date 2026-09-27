{
  lib,
  config,
  pkgs,
  ...
}:
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
      ]
      ++ lib.optional cfg.backup.enable "restic-backups-immich";
    };
    mediaDir = lib.mkOption {
      type = lib.types.path;
      default = "/storage/immich";
    };
    accelerationDevices = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      description = "Path to the accelarator device";
    };

    backup = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable immich backups";
      };
      passwordFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to restic password file";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "d ${cfg.mediaDir} 0775 immich immich - -" ];
    services.${service} = {
      enable = true;
      # FIXME: immich is broken on stable 26.05
      package = pkgs.unstable.immich;
      port = cfg.port;
      openFirewall = !homelab.services.reverseProxy.enable;
      mediaLocation = "${cfg.mediaDir}";
      inherit (cfg) accelerationDevices;
      machine-learning.enable = false;
      settings = {
        backup.database = {
          enabled = true;
          cronExpression = "0 02 * * *";
          keepLastAmount = 5;
        };
        server.externalDomain = "https://${cfg.url}";
      };
    };
    services.restic.backups.immich = lib.mkIf cfg.backup.enable {
      initialize = true;
      repository = "sftp:hetzner-storage-immich:/home/immich-backup";
      passwordFile = cfg.backup.passwordFile;
      paths = [
        # files
        "${cfg.mediaDir}/upload"
        # db dump
        "${cfg.mediaDir}/backups"
      ];
      timerConfig = {
        OnCalendar = "03:00";
        Persistent = true;
      };
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 12"
      ];
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://${config.services.immich.host}:${toString cfg.port}
      '';
    };

  };
}
