{ lib, config, ... }:
let
  inherit (config) homelab;
  cfg = homelab.reverseProxy;
in
{
  options.homelab.reverseProxy = {
    enable = lib.mkEnableOption "Enable caddy reverse proxy";
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
  };

  config = lib.mkIf cfg.enable {

    # get the certs
    security.acme = {
      acceptTerms = true;
      defaults.email = "${homelab.email}";
      certs.${homelab.baseDomain} = {
        inherit (config.services.caddy) group;
        reloadServices = [ "caddy.service" ];
        extraDomainNames = [ "*.${homelab.baseDomain}" ];
        dnsProvider = cfg.dnsProvider;
        dnsResolver = cfg.dnsResolver;
        environmentFile = cfg.dnsCredentialsFile;
      };
    };

    services.caddy = {
      enable = true;
      globalConfig = "auto_https off";
      virtualHosts = {
        "http://${homelab.baseDomain}" = {
          extraConfig = "redir https://{host}{uri}";
        };
        "http://*.${homelab.baseDomain}" = {
          extraConfig = "redir https://{host}{uri}";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
