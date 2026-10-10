{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (config) homelab;
  service = "vaultwarden";
  cfg = homelab.services.${service};
  backupDir = "/var/backup/vaultwarden";
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "vault.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8222;
    };
    monitoredServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "vaultwarden"
        "backup-vaultwarden"
      ]
      ++ lib.optional cfg.backup.enable "restic-backups-vaultwarden";
    };
    backup = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable vaultwarden backups";
      };
      host = lib.mkOption {
        type = lib.types.str;
        default = "hetzner-vaultwarden-backup";
        description = "Name for backup host";
      };
      user = lib.mkOption {
        type = lib.types.str;
        description = "Remote user";
      };
      address = lib.mkOption {
        type = lib.types.str;
        description = "Address to remote backup location";
      };
      sshKeyPath = lib.mkOption {
        type = lib.types.path;
        description = "Path to remote key file";
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
        default = "/home/vaultwarden-backup";
        description = "Path to restic repository in the remote";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    homelab.ports = [ cfg.port ];
    services.${service} = {
      enable = true;
      package = pkgs.vaultwarden;
      backupDir = backupDir;
      config = {
        DOMAIN = "https://${cfg.url}";
        SIGNUPS_ALLOWED = false;
        EXTENDED_LOGGING = true;
        LOG_LEVEL = "warn";
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = cfg.port;
      };
    };
    services.restic.backups.vaultwarden = lib.mkIf cfg.backup.enable {
      initialize = true;
      repository = "sftp:${cfg.backup.host}:${cfg.backup.repositoryPath}";
      passwordFile = cfg.backup.passwordFile;
      paths = [
        backupDir
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
        encode zstd gzip
        reverse_proxy http://127.0.0.1:${toString cfg.port} {
          header_up X-Real-IP {remote_host}
        }
      '';
    };
  };
}
