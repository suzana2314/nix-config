{ inputs, config, ... }:
let
  sopsFile = "${builtins.toString inputs.nix-secrets}/sops/${config.networking.hostName}.yaml";
  secrets = inputs.nix-secrets;
  hostCfg = secrets.networking.subnets.default.hosts.hemwick;

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
    externalIP = hostCfg.ip;

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

    cloudflare.dnsCredentialsFile = config.sops.secrets."cloudflare/dnsCredentials".path;

    services = {
      enable = true;

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
        cloudflared.enable = false;
      };

      esphome = {
        enable = true;
        auth = config.sops.secrets.esphome.path;
      };

      mosquitto.enable = true;
      gree-server.enable = true;
      scanservjs.enable = true;

      glance = {
        enable = true;
        apiToken = config.sops.secrets."glance/byrgenwerthApitoken".path;
      };

      miniflux = {
        enable = true;
        environmentFile = config.sops.secrets."miniflux/environmentFile".path;
      };

      extraCaddyHosts = {
        enable = true;
        hosts = {
          sovol.enable = true;
          sovol.host = secrets.networking.services.sovol;
          freeds.enable = true;
          freeds.host = secrets.networking.services.freeds;
        };
      };

      newt = {
        enable = true;
        environmentFile = config.sops.secrets."newt/environmentFile".path;
      };

      grafana.enable = true;
      prometheus-node.enable = true;
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
    esphome = mkSecret;
    "glance/byrgenwerthApitoken" = mkSecret;
    "miniflux/environmentFile" = mkSecret;
    "newt/environmentFile" = mkSecret;
    "prometheus/hostsPasswordFile" = mkUserSecret config.users.users.prometheus.name;
  };
}
