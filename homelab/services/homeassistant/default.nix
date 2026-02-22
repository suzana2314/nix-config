{ config, lib, ... }:
let
  service = "homeassistant";
  inherit (config) homelab;
  cfg = homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable Home Assistant";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8123;
    };
    zigbee = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Zigbee coordinator support";
      };
      coordinatorPath = lib.mkOption {
        type = lib.types.str;
        description = "Path to the Zigbee coordinator device";
      };
    };
    shelly = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Shelly CoIoT support";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 5683;
        description = "Default CoIoT udp port";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "d ${cfg.configDir} 0775 ${homelab.user} ${homelab.group} - -" ];

    virtualisation = {
      oci-containers = {
        containers = {
          homeassistant = {
            image = "ghcr.io/home-assistant/home-assistant:stable";
            autoStart = true;
            extraOptions = [
              "--pull=newer"
              "--cap-add=CAP_NET_RAW"
            ]
            ++ lib.optionals cfg.zigbee.enable [
              "--device=${cfg.zigbee.coordinatorPath}"
            ];
            volumes = [
              "${cfg.configDir}:/config"
            ];
            ports = [
              "127.0.0.1:${toString cfg.port}:${toString cfg.port}"
            ]
            ++ lib.optionals cfg.shelly.enable [
              "127.0.0.1:${toString cfg.shelly.port}:${toString cfg.shelly.port}/udp"
            ];
            environment = {
              TZ = homelab.timeZone;
              PUID = toString config.users.users.${homelab.user}.uid;
              PGID = toString config.users.groups.${homelab.group}.gid;
            };
          };
        };
      };
    };

    networking.firewall = lib.mkIf cfg.shelly.enable {
      allowedUDPPorts = [ cfg.shelly.port ];
    };

    services.caddy.virtualHosts."${cfg.url}" = lib.mkIf homelab.enableCaddy {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
