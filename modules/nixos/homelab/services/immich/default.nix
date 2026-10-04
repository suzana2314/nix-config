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
      host = lib.mkOption {
        type = lib.types.str;
        default = "hetzner-immich-backup";
        description = "Name for backup host";
      };
      user = lib.mkOption {
        type = lib.types.str;
        description = "Remote user";
      };
      address = lib.mkOption {
        type = lib.types.str;
        description = "Address for remote backup location";
      };
      sshKeyPath = lib.mkOption {
        type = lib.types.path;
        description = "Path to remove key file";
      };
      remotePublicKey = lib.mkOption {
        type = lib.types.str;
        description = "The remote public key used for known hosts";
      };
      passwordFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to restic password file";
      };
      repositoryPath = lib.mkOption {
        type = lib.types.str;
        default = "/home/immich-backup";
        description = "Path to restic repository in the remote";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "d ${cfg.mediaDir} 0775 immich immich - -" ];
    homelab.ports = [ cfg.port ];
    services.${service} = {
      enable = true;
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
      repository = "sftp:${cfg.backup.host}:${cfg.backup.repositoryPath}";
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

    programs.ssh = lib.mkIf cfg.backup.enable {
      knownHosts.${cfg.backup.host} = {
        hostNames = [ cfg.backup.address ];
        publicKey = cfg.backup.remotePublicKey;
      };
      extraConfig = ''
        Host ${cfg.backup.host}
          IdentitiesOnly yes
          User ${cfg.backup.user}
          Hostname ${cfg.backup.address}
          IdentityFile ${cfg.backup.sshKeyPath}
          Port 23
      '';
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://${config.services.immich.host}:${toString cfg.port}
      '';
    };
  };
}
