{ lib, config, pkgs, ... }:
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
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      package = pkgs.unstable.grafana;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 2342;
          domain = cfg.url;
          root_url = "https://${cfg.url}";
          serve_from_sub_path = false;
          enforce_domain = true;
        };
        security = {
          allow_embedding = true;
          cookie_secure = true;
          cookie_samesite = "lax";
        };
      };
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        encode gzip
        reverse_proxy http://127.0.0.1:2342 {
          header_up X-Forwarded-Proto {http.request.scheme}
          header_up X-Forwarded-Host {host}
          header_up Host {host}
        }
      '';
    };
  };
}
