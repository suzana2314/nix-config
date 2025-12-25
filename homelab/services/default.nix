{ lib, config, ... }:
{
  options.homelab.services = {
    enable = lib.mkEnableOption "Services for homelab";
  };

  config = lib.mkIf config.homelab.services.enable {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    security.acme = lib.mkIf config.homelab.enableCaddy {
      acceptTerms = true;
      defaults.email = "${config.homelab.email}";
      certs.${config.homelab.baseDomain} = {
        inherit (config.services.caddy) group;
        reloadServices = [ "caddy.service" ];
        extraDomainNames = [ "*.${config.homelab.baseDomain}" ];
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        dnsPropagationCheck = true;
        environmentFile = config.homelab.cloudflare.dnsCredentialsFile;
      };
    };

    services.caddy = lib.mkIf config.homelab.enableCaddy {
      enable = true;
      globalConfig = ''auto_https off'';
      virtualHosts = {
        "http://${config.homelab.baseDomain}" = {
          extraConfig = ''redir https://{host}{uri}'';
        };
        "http://*.${config.homelab.baseDomain}" = {
          extraConfig = ''redir https://{host}{uri}'';
        };
      };
    };

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      autoPrune.enable = true;
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };
    virtualisation.oci-containers = {
      backend = "podman";
    };

    networking.firewall.interfaces.podman0.allowedUDPPorts =
      lib.lists.optionals config.virtualisation.podman.enable
        [ 53 ];
  };

  imports = [
    ./ddns
    ./dns
    ./esphome
    ./extracaddyhosts
    ./frigate
    ./glance
    ./glance-agent
    ./gotify
    ./grafana
    ./gree-server
    ./hoarder
    ./homeassistant
    ./immich
    ./media
    ./miniflux
    ./mqtt
    ./prometheus-node
    ./prometheus-server
    ./uptime-kuma
    ./wireguard-netns
    ./wireguard-server
    ./scanservjs
    ./newt
  ];
}
