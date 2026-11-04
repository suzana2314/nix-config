{ lib, ... }:
{
  options.homelab.services.reverseProxy = {
    enable = lib.mkEnableOption "Enable caddy reverse proxy";
    monitoredServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "caddy"
      ];
    };
    dnsProvider = lib.mkOption {
      type = lib.types.str;
      description = "The DNS provider to use for ACME DNS-01 challenges";
    };
    dnsResolver = lib.mkOption {
      type = lib.types.str;
      description = "The DNS resolver address used to verify DNS-01 challenge propagation";
    };
    dnsCredentialsFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the file containing DNS provider credentials for ACME DNS-01 challenges";
    };
    metrics = {
      enable = lib.mkOption {
        type = lib.types.bool;
      };
      environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to environment file containing CADDY_METRICS_AUTH_HASH";
      };
    };
  };
  imports = [
    ./caddy.nix
    ./acme.nix
  ];
}
