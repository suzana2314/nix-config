{ lib, config, ... }:
{
  options.homelab.services = {
    enable = lib.mkEnableOption "Services for homelab";
  };

  config = lib.mkIf config.homelab.services.enable {
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
    ./frigate
    ./glance
    ./glance-agent
    ./grafana
    ./gree-server
    ./homeassistant
    ./immich
    ./media
    ./miniflux
    ./mqtt
    ./prometheus
    ./prometheus/exporters
    ./wireguard-netns
    ./wireguard-server
    ./scanservjs
    ./newt
    ./radicale
    ./vaultwarden
    ./reverse-proxy
    ./readeck
  ];
}
