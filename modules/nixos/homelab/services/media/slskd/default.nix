{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config) homelab;
  service = "slskd";
  cfg = homelab.services.${service};
in
{
  imports = [ ./beets.nix ];
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
      default = 5030;
    };
    soulseekPort = lib.mkOption {
      type = lib.types.port;
    };
    musicDir = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "/storage/music";
    };
    downloadDir = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "/storage/music/downloads";
    };
    incompleteDownloadDir = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "/storage/music/downloads/incomplete";
    };
    beetsConfigFile = lib.mkOption {
      type = lib.types.path;
    };
    environmentFile = lib.mkOption {
      description = "Environment file with slskd credentials";
      type = lib.types.path;
      example = lib.literalExpression ''
        pkgs.writeText "slskd-env" '''
          SLSKD_PASSWORD=example
          SLSKD_USERNAME=example
        '''
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    homelab.ports = [
      cfg.port
      cfg.soulseekPort
    ];
    services.${service} = {
      enable = true;
      inherit (homelab) user group;
      environmentFile = cfg.environmentFile;
      domain = null;
      settings = {
        web.port = cfg.port;
        directories = {
          incomplete = cfg.incompleteDownloadDir;
          downloads = cfg.downloadDir;
        };
        soulseek.listen_port = cfg.soulseekPort;
        shares = {
          directories = [
            cfg.musicDir
            "!${cfg.musicDir}/.beets"
          ];
          filters = [
            "\.ini$"
            "Thumbs.db$"
            "\.DS_Store$"
          ];
        };
        integration.scripts.slskd-import-files = {
          on = [
            "DownloadDirectoryComplete"
          ];
          run =
            let
              slskd-import-files = pkgs.writeShellScript "slskd-import-files" ''
                export BEETSDIR=${cfg.musicDir}/.beets
                ${lib.getExe pkgs.beets} -c ${cfg.beetsConfigFile} import -m -q ${cfg.downloadDir} \
                  >> ${cfg.musicDir}/.beets/import.log 2>&1
                code=$?
                echo "exit code: $code" >> ${cfg.musicDir}/.beets/import.log
                exit $code
              '';
            in
            {
              executable = "${slskd-import-files}";
            };
        };
      };
    };
    systemd.services.slskd.serviceConfig.ReadWritePaths = [ cfg.musicDir ];
    networking.firewall = {
      allowedTCPPorts = [ cfg.soulseekPort ];
      allowedUDPPorts = [ cfg.soulseekPort ];
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
