{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "storagebox-exporter";
  cfg = homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "storagebox-metrics.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 9509;
    };
    tokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to token file containing the hetzner api key";
    };
    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to environment file containing STORAGEBOX_EXPORTER_AUTH_HASH";
    };
  };

  config = lib.mkIf cfg.enable {
    homelab.ports = [ cfg.port ];
    services.prometheus.exporters.storagebox = {
      inherit (cfg) port tokenFile;
      enable = true;
    };
    systemd.services.caddy.serviceConfig.EnvironmentFile = lib.mkIf (cfg.environmentFile != null) [
      cfg.environmentFile
    ];
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        ${lib.optionalString (cfg.environmentFile != null) ''
          basic_auth {
            prometheus-oedon {$STORAGEBOX_EXPORTER_AUTH_HASH}
          }
        ''}
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
