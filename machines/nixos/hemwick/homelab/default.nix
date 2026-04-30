{ inputs, config, ... }:
let
  host = config.networking.hostName;
  secrets = inputs.nix-secrets;
  sopsFile = "${builtins.toString secrets}/sops/${host}.yaml";

  mkSecret = {
    inherit sopsFile;
    mode = "0400";
  };
  mkUserSecret = owner: mkSecret // { inherit owner; };
in
{
  homelab = {
    enable = true;
    inherit (config.time) timeZone;
    email = secrets.email.default;
    baseDomain = secrets.domain;

    motd = {
      enable = true;
      asciiArt = ''
        ██╗  ██╗███████╗███╗   ███╗██╗    ██╗██╗ ██████╗██╗  ██╗
        ██║  ██║██╔════╝████╗ ████║██║    ██║██║██╔════╝██║ ██╔╝
        ███████║█████╗  ██╔████╔██║██║ █╗ ██║██║██║     █████╔╝
        ██╔══██║██╔══╝  ██║╚██╔╝██║██║███╗██║██║██║     ██╔═██╗
        ██║  ██║███████╗██║ ╚═╝ ██║╚███╔███╔╝██║╚██████╗██║  ██╗
        ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝ ╚══╝╚══╝ ╚═╝ ╚═════╝╚═╝  ╚═╝
      '';
    };

    services = {
      enable = true;

      reverseProxy = {
        enable = true;
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        dnsCredentialsFile = config.sops.secrets."cloudflare/dnsCredentials".path;
      };

      dns = {
        enable = true;
        url = "dns1.${secrets.domain}";
        dnsMappings = secrets.dnsMappings;
        dnsRewrites = secrets.dnsRewrites;
      };

      ddns-updater = {
        enable = true;
        configFile = config.sops.secrets."cloudflare/ddnsCredentials".path;
        notifications = config.sops.secrets."cloudflare/ddnsNotification".path;
      };

      homeassistant = {
        enable = true;
        shelly.enable = true;
        zigbee = {
          enable = true;
          coordinatorPath = "/dev/serial/by-id/usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_V2_20231031155326-if00";
        };
      };

      esphome = {
        enable = true;
        environmentFile = config.sops.secrets."esphome/environmentFile".path;
      };

      readeck = {
        enable = true;
        environmentFile = config.sops.secrets."readeck/environmentFile".path;
      };

      mosquitto.enable = true;
      gree-server.enable = true;
      scanservjs.enable = true;
      vaultwarden.enable = true;

      glance = {
        enable = true;
        apiToken = config.sops.secrets."glance/byrgenwerthApitoken".path;
      };

      miniflux = {
        enable = true;
        environmentFile = config.sops.secrets."miniflux/environmentFile".path;
      };

      radicale = {
        enable = true;
        passwdFile = config.sops.secrets."radicale/passwdFile".path;
      };

      webdav = {
        enable = true;
        environmentFile = config.sops.secrets."webdav/environmentFile".path;
      };

      newt = {
        enable = true;
        environmentFile = config.sops.secrets."newt/environmentFile".path;
      };

      endurain = {
        enable = true;
        environmentFile = config.sops.secrets."endurain/environmentFile".path;
      };

      grafana.enable = true;
      prometheus-node-exporter.enable = true;
      prometheus = {
        enable = true;
        scrapeConfigs = import ./scrape-configs.nix { inherit config; };
      };
    };
  };

  # secrets for the homelab config
  sops.secrets = {
    "cloudflare/dnsCredentials" = mkUserSecret config.users.users.acme.name;
    "cloudflare/ddnsCredentials" = mkUserSecret config.users.users.ddns-updater.name;
    "cloudflare/ddnsNotification" = mkUserSecret config.users.users.ddns-updater.name;
    "radicale/passwdFile" = mkUserSecret config.users.users.radicale.name;
    "webdav/environmentFile" = mkUserSecret config.users.users.webdav.name;
    "prometheus/hostsPasswordFile" = mkUserSecret config.users.users.prometheus.name;
    "glance/byrgenwerthApitoken" = mkSecret;
    "esphome/environmentFile" = mkSecret;
    "miniflux/environmentFile" = mkSecret;
    "newt/environmentFile" = mkSecret;
    "readeck/environmentFile" = mkSecret;
    "endurain/environmentFile" = mkSecret;
  };
}
