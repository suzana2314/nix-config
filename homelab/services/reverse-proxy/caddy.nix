{ lib, config, ... }:
let
  inherit (config) homelab;
  host = config.networking.hostName;
  cfg = homelab.services.reverseProxy;
in
{
  config = lib.mkIf cfg.enable {
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
        "http://.${homelab.baseDomain}" = {
          extraConfig = "redir https://{host}{uri}";
        };
        # metrics
        "${host}.${homelab.baseDomain}" = {
          useACMEHost = homelab.baseDomain;
          extraConfig = ''
            metrics /caddy/metrics
          '';
        };
      };
    };
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
