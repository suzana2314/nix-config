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
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.node = {
      inherit (cfg) port;
      enable = true;
      enabledCollectors = [ "systemd" ];
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy /metrics http://127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
