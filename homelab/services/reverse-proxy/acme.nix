{ lib, config, ... }:
let
  inherit (config) homelab;
  cfg = homelab.services.reverseProxy;
in
{
  config = lib.mkIf cfg.enable {
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
  };
}
