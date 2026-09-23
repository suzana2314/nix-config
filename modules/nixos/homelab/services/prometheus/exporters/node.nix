{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "prometheus-node-exporter";
  host = config.networking.hostName;
  cfg = homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${host}.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 9100;
    };
    environmentFile = lib.mkOption {
      type = lib.types.path;
      default = null;
      description = "Path to environment file containing NODE_EXPORTER_AUTH_HASH";
    };
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.node = {
      inherit (cfg) port;
      enable = true;
      enabledCollectors = [ "systemd" ];
    };
    systemd.services.caddy.serviceConfig.EnvironmentFile = lib.mkIf (cfg.environmentFile != null) [
      cfg.environmentFile
    ];
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        ${lib.optionalString (cfg.environmentFile != null) ''
          basic_auth /metrics {
            prometheus-oedon {$NODE_EXPORTER_AUTH_HASH}
          }
        ''}
        reverse_proxy /metrics http://127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
