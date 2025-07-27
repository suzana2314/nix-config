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
    outUrl = lib.mkOption {
      type = lib.types.str;
      default = "ha-access.${homelab.baseDomain}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
    };
    zigbee = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Zigbee coordinator support";
      };
      coordinatorPath = lib.mkOption {
        type = lib.types.str;
        default = "/dev/serial/by-id/usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_V2_20231031155326-if00";
        description = "Path to the Zigbee coordinator device";
      };
    };
    shelly = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Shelly CoIoT support";
      };
    };
    cloudflared.credentialsFile = lib.mkOption {
      type = lib.types.str;
      example = lib.literalExpression ''
        pkgs.writeText "cloudflare-credentials.json" '''
        {"AccountTag":"secret"."TunnelSecret":"secret","TunnelID":"secret"}
        '''
      '';
    };
    cloudflared.tunnelId = lib.mkOption {
      type = lib.types.str;
      example = "00000000-0000-0000-0000-000000000000";
    };
  };
  config = lib.mkIf cfg.enable {

    systemd.tmpfiles.rules = [ "d ${cfg.configDir} 0775 ${homelab.user} ${homelab.group} - -" ];
    services.caddy.virtualHosts."${cfg.url}" = lib.mkIf homelab.enableCaddy {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:8123
      '';
    };
    services.cloudflared = {
      enable = true;
      tunnels.${cfg.cloudflared.tunnelId} = {
        inherit (cfg.cloudflared) credentialsFile;
        default = "http_status:404";
        ingress."${cfg.outUrl}".service = "http://127.0.0.1:8123";
      };
    };
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
              "8123:8123"
              "8124:80"
            ]
            ++ lib.optionals cfg.shelly.enable [
              "5683:5683" # this is for colIoT
              "5683:5683/udp"
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
  };
}
