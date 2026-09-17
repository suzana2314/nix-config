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
      ntfy = {
        bridgePort = lib.mkOption {
          type = lib.types.port;
          default = 8111;
        };
        baseUrl = lib.mkOption {
          type = lib.types.str;
          default = "https://ntfy.sh";
        };
        extraConfigFiles = lib.mkOption {
          type = lib.types.listOf lib.types.path;
          default = [ ];
        };
        topic = lib.mkOption {
          type = lib.types.str;
          default = "alerts";
          description = "ntfy topic to publish alerts to";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
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
            receiver = "ntfy";
            group_by = [ "alertname" ];
            group_wait = "30s";
            group_interval = "5m";
            repeat_interval = "3h";
          };
          receivers = [
            {
              name = "ntfy";
              webhook_configs = [
                {
                  url = "http://127.0.0.1:${toString cfg.alertmanager.ntfy.bridgePort}/hook";
                }
              ];
            }
          ];
        };
      };

      alertmanager-ntfy = lib.mkIf cfg.alertmanager.enable {
        enable = true;
        inherit (cfg.alertmanager.ntfy) extraConfigFiles;
        settings = {
          http.addr = ":${toString cfg.alertmanager.ntfy.bridgePort}";
          ntfy = {
            baseurl = cfg.alertmanager.ntfy.baseUrl;
            notification = {
              topic = cfg.alertmanager.ntfy.topic;
              priority = ''status == "firing" ? "high" : "default"'';
            };
          };
        };
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
