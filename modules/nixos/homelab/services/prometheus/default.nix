{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "prometheus";
  cfg = homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "metrics.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 9090;
    };
    scrapeConfigs = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      description = "The jobs to scrape";
    };
    alertRules = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = "Prometheus alerting rule groups";
    };
    alertmanager = {
      enable = lib.mkEnableOption {
        description = "Enable alertmanager";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 9093;
      };
      url = lib.mkOption {
        type = lib.types.str;
        default = "alerts.${homelab.baseDomain}";
      };
      gotify = {
        bridgePort = lib.mkOption {
          type = lib.types.port;
          default = 8111;
        };
        host = lib.mkOption {
          type = lib.types.str;
          default = "gotify.example.com";
        };
        port = lib.mkOption {
          type = lib.types.port;
          default = 443;
        };
        environmentFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = ''
            File with env vars for the bridge:
            GOTIFY_TOKEN=<some-token>
          '';
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    homelab.ports = [
      cfg.port
    ]
    ++ lib.optionals cfg.alertmanager.enable [
      cfg.alertmanager.port
      cfg.alertmanager.gotify.bridgePort
    ];
    services.prometheus = {
      enable = true;
      globalConfig.scrape_interval = "30s";
      inherit (cfg) scrapeConfigs port;

      ruleFiles = lib.optional (cfg.alertRules != [ ]) (
        builtins.toFile "prometheus-rules.yml" (builtins.toJSON { groups = cfg.alertRules; })
      );

      alertmanagers = lib.mkIf cfg.alertmanager.enable [
        {
          static_configs = [ { targets = [ "127.0.0.1:${toString cfg.alertmanager.port}" ]; } ];
        }
      ];

      alertmanager = lib.mkIf cfg.alertmanager.enable {
        enable = true;
        port = cfg.alertmanager.port;
        webExternalUrl = "https://${cfg.alertmanager.url}";
        configuration = {
          route = {
            receiver = "gotify";
            group_by = [ "alertname" ];
            group_wait = "30s";
            group_interval = "5m";
            repeat_interval = "3h";
          };
          receivers = [
            {
              name = "gotify";
              webhook_configs = [
                {
                  url = "http://127.0.0.1:${toString cfg.alertmanager.gotify.bridgePort}/gotify_webhook";
                }
              ];
            }
          ];
        };
      };

      alertmanagerGotify = lib.mkIf cfg.alertmanager.enable {
        enable = true;
        port = cfg.alertmanager.gotify.bridgePort;
        webhookPath = "/gotify_webhook";
        titleAnnotation = "summary";
        messageAnnotation = "description";
        metrics.username = "alertmanager";

        gotifyEndpoint = {
          inherit (cfg.alertmanager.gotify) host port;
        };
        inherit (cfg.alertmanager.gotify) environmentFile;
      };
    };
    services.caddy.virtualHosts = {
      "${cfg.url}" = {
        useACMEHost = homelab.baseDomain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:${toString cfg.port}
        '';
      };
      "${cfg.alertmanager.url}" = {
        useACMEHost = homelab.baseDomain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:${toString cfg.alertmanager.port}
        '';
      };
    };
  };
}
