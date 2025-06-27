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
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
    };
    auth = lib.mkOption {
      type = lib.types.str;
      description = "Path to environment file containing USERNAME and PASSWORD";
    };
  };

  config = lib.mkIf cfg.enable {
    # user is not being created?
    users.users.esphome = {
      isSystemUser = true;
      group = "esphome";
    };
    users.groups.esphome = { };

    services.${service} = {
      enable = true;
      usePing = false;
      allowedDevices = [ ];
    };
    systemd.services.${service}.serviceConfig = {
      EnvironmentFile = [ cfg.auth ];
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:6052
      '';
    };
  };
}
