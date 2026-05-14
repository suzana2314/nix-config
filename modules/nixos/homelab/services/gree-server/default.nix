{
  inputs,
  lib,
  config,
  ...
}:
let
  inherit (config) homelab;
  service = "gree-server";
  cfg = homelab.services.${service};
  host = config.networking.hostName;
  net = inputs.nix-secrets.networking.hosts.${host};
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
    monitoredServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "${config.virtualisation.oci-containers.backend}-${service}"
      ];
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers = {
      containers = {
        ${service} = {
          image = "codeberg.org/joserebelo/gree-dummy-tls-server:latest";
          autoStart = true;
          environment = {
            DOMAIN_NAME = "${cfg.url}";
            EXTERNAL_IP = "${net.ip}";
          };
          ports = [
            "${cfg.tlsPort}:1813" # tls
            "${cfg.tcpPort}:5000"
          ];
        };
      };
    };
  };
}
