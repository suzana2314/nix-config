{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "gree-server";
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
    tlsPort = lib.mkOption {
      type = lib.types.str;
      default = "1813";
    };
    tcpPort = lib.mkOption {
      type = lib.types.str;
      default = "5000";
    };
    prometheusPort = lib.mkOption {
      type = lib.types.str;
      default = "5555";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers = {
      containers = {
        gree-dummy-tls-server = {
          image = "codeberg.org/joserebelo/gree-dummy-tls-server:latest
";
          autoStart = true;
          environment = {
            DOMAIN_NAME = "${cfg.url}";
            EXTERNAL_IP = "${config.homelab.externalIP}";
            LISTEN_PORT_PROMETHEUS = "${cfg.prometheusPort}";
          };
          ports = [
            "${cfg.tlsPort}:${cfg.tlsPort}" # tls
            "${cfg.tcpPort}:${cfg.tcpPort}"
            "${cfg.prometheusPort}:${cfg.prometheusPort}"
          ];
        };
      };
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:5000
      '';
    };
  };
}
