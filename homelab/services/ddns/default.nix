{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "ddns-updater";
  cfg = homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    configFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the config.json file";
    };
    notifications = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.ddns-updater = {
      isSystemUser = true;
      group = "ddns-updater";
    };
    users.groups.ddns-updater = { };
    systemd.services.ddns-updater-setup = {
      description = "Setup DDNS updater configuration";
      before = [ "ddns-updater.service" ];
      wantedBy = [ "ddns-updater.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = config.users.users.ddns-updater.name;
        Group = config.users.users.ddns-updater.name;
        StateDirectory = "ddns-updater";
      };
      script = ''
        cp ${cfg.configFile} ${cfg.configDir}/config.json
        chmod 600 ${cfg.configDir}/config.json
        chown ${config.users.users.ddns-updater.name}:${config.users.users.ddns-updater.name} ${cfg.configDir}/config.json
      '';
    };
    systemd.services.ddns-updater = {
      serviceConfig = {
        EnvironmentFile = lib.mkIf (cfg.notifications != "") "${cfg.notifications}";
      };
    };
    services.${service} = {
      enable = true;
      environment = {
        CONFIG_FILEPATH = "${cfg.configDir}/config.json";
        DATADIR = "${cfg.configDir}";
      };
    };
  };
}
