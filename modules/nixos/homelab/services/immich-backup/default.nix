{
  lib,
  config,
  ...
}:
let
  inherit (config) homelab;
  service = "immich-backup";
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
    passwordFile = lib.mkOption {
      type = lib.types.path;
      description = "path to restic password file";
    };
  };

  config = lib.mkIf cfg.enable {
    services.restic.backups.immich = {
      initialize = true;
      repository = "sftp:hetzner-storage-immich:/home/immich-backup";
      passwordFile = cfg.passwordFile;

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
  };
}
