{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "webdav";
  cfg = homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}/collections";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8904;
    };
    environmentFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to environment file containing USERNAME and PASSWORD";
      example = ''
        USERNAME=john_doe
        PASSWORD=hunter2
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.tmpfiles.rules = [
      "d ${cfg.configDir} 0700 ${service} ${service} -"
      "d ${cfg.configDir}/runner 0700 ${service} ${service} -"
      "d ${cfg.configDir}/backup 0700 ${service} ${service} -"
    ];

    services.${service} = {
      enable = true;
      environmentFile = cfg.environmentFile;
      settings = {
        address = "127.0.0.1";
        port = cfg.port;
        behindProxy = true;
        directory = cfg.configDir;
        users = [
          {
            username = "{env}USERNAME_RUNNER";
            password = "{env}PASSWORD_RUNNER";
            directory = "${cfg.configDir}/runner";
            permissions = "CR";
          }
          {
            username = "{env}USERNAME_BACKUP";
            password = "{env}PASSWORD_BACKUP";
            directory = "${cfg.configDir}/backup";
            permissions = "CRUD";
          }
        ];
      };
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };

  };
}
