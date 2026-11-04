{ lib, config, ... }:
let
  inherit (config) homelab;
  host = config.networking.hostName;
  cfg = homelab.services.reverseProxy;
in
{
  config = lib.mkIf cfg.enable {
    homelab.ports = [
      80
      443
    ];
    services.caddy = {
      enable = true;
      globalConfig = ''
        auto_https off
        metrics {
          per_host
        }
      '';
      virtualHosts = {
        "http://${homelab.baseDomain}" = {
          extraConfig = "redir https://{host}{uri}";
        };
        "http://*.${homelab.baseDomain}" = {
          extraConfig = "redir https://{host}{uri}";
        };
        # metrics
        "${host}.${homelab.baseDomain}" = lib.mkIf cfg.metrics.enable {
          useACMEHost = homelab.baseDomain;
          extraConfig = ''
            ${lib.optionalString (cfg.metrics.environmentFile != null) ''
              basic_auth /caddy/metrics {
                prometheus-oedon {$CADDY_METRICS_AUTH_HASH}
              }
            ''}
            metrics /caddy/metrics
          '';
        };
      };
    };
    systemd.services.caddy.serviceConfig.EnvironmentFile = lib.optional (
      cfg.metrics.enable && cfg.metrics.environmentFile != null
    ) cfg.metrics.environmentFile;
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
