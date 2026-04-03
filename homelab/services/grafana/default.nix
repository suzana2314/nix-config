{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (config) homelab;
  service = "grafana";
  cfg = homelab.services.${service};
in
{
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
      default = 2342;
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      package = pkgs.unstable.grafana;
      openFirewall = !homelab.reverseProxy.enable;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = cfg.port;
          domain = cfg.url;
          root_url = "https://${cfg.url}";
          serve_from_sub_path = false;
          enforce_domain = true;
        };
        dashboards.default_home_dashboard_path = "${./dashboards}/system_status.json";
        security = {
          allow_embedding = true;
          cookie_secure = true;
          cookie_samesite = "lax";
        };
      };
      provision = {
        enable = true;
        dashboards.settings.providers = [
          {
            options.path = ./dashboards;
          }
        ];
        datasources.settings = {
          apiVersion = 1;
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              access = "proxy";
              url = "https://metrics.${homelab.baseDomain}";
              uid = "prometheus-default";
              isDefault = true;
            }
          ];
        };
      };
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        encode gzip
        reverse_proxy http://127.0.0.1:${toString cfg.port} {
          header_up X-Forwarded-Proto {http.request.scheme}
          header_up X-Forwarded-Host {host}
          header_up Host {host}
        }
      '';
    };
  };
}
