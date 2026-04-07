{
  baseDomain,
  cfg,
  net,
}:
{
  server = {
    host = "localhost";
    port = cfg.port;
    proxied = true;
    assets-path = cfg.assetsPath;
  };

  theme = {
    # gruvbox hard
    background-color = "195 6 12";
    primary-color = "43 59 81";
    positive-color = "61 66 44";
    negative-color = "6 96 59";
  };

  branding = {
    hide-footer = true;
    logo-text = "S";
  };

  pages = [
    {
      name = "Main";
      head-widgets = [
        {
          type = "monitor";
          cache = "1m";
          title = "Services";
          sites = [
            {
              title = "Miniflux";
              url = "https://miniflux.${baseDomain}";
              icon = "/assets/miniflux-light.svg";
            }
            {
              title = "Home Assistant";
              url = "https://homeassistant.${baseDomain}";
              icon = "/assets/home-assistant.svg";
            }
            {
              title = "Jellyfin";
              url = "https://jellyfin.${baseDomain}";
              icon = "/assets/jellyfin.svg";
            }
            {
              title = "Navidrome";
              url = "https://navidrome.${baseDomain}";
              icon = "/assets/navidrome.png";
            }
            {
              title = "Immich";
              url = "https://immich.${baseDomain}";
              icon = "/assets/immich.svg";
            }
          ];
        }
      ];
      columns = [
        {
          size = "small";
          widgets = [
            {
              type = "server-stats";
              servers = [
                {
                  type = "local";
                  hide-mountpoints-by-default = true;
                  mountpoints = {
                    "/" = {
                      hide = false;
                      name = "root";
                    };
                  };
                }
                {
                  type = "remote";
                  url = "https://byrgenwerth-glance.${baseDomain}";
                  token = {
                    _secret = cfg.apiToken;
                  };
                }
              ];
            }
          ];
        }
        {
          size = "full";
          widgets = [
            {
              type = "reddit";
              subreddit = "portugal";
            }
          ];
        }
        {
          size = "small";
          widgets = [
            {
              type = "calendar";
            }
          ];
        }
      ];
    }
    {
      name = "Services";
      center-vertically = true;
      columns = [
        {
          size = "full";
          widgets = [
            {
              type = "monitor";
              cache = "1m";
              title = "Home";
              sites = [
                {
                  title = "Home Assistant";
                  url = "https://homeassistant.${baseDomain}";
                  icon = "/assets/home-assistant.svg";
                }
                {
                  title = "ESPHome";
                  url = "https://esphome.${baseDomain}";
                  icon = "/assets/esphome.svg";
                }
                {
                  title = "Frigate";
                  url = "https://frigate.${baseDomain}";
                  icon = "/assets/frigate-light.svg";
                }
                {
                  title = "FreeDS";
                  url = "http://freeds.${baseDomain}";
                  icon = "/assets/freeds.png";
                  alt-status-codes = [
                    403
                    401
                  ];
                }
              ];
            }
            {
              type = "monitor";
              cache = "1m";
              title = "Media";
              sites = [
                {
                  title = "Immich";
                  url = "https://immich.${baseDomain}";
                  icon = "/assets/immich.svg";
                }
                {
                  title = "Jellyfin";
                  url = "https://jellyfin.${baseDomain}";
                  icon = "/assets/jellyfin.svg";
                }
                {
                  title = "Jellyseerr";
                  url = "https://jellyseerr.${baseDomain}";
                  icon = "/assets/jellyseerr.svg";
                }
                {
                  title = "Navidrome";
                  url = "https://navidrome.${baseDomain}";
                  icon = "/assets/navidrome.png";
                }
                {
                  title = "qBitTorrent";
                  url = "https://qbittorrent.${baseDomain}";
                  icon = "/assets/qbittorrent.svg";
                }
              ];
            }
            {
              type = "monitor";
              cache = "1m";
              title = "Arr";
              sites = [
                {
                  title = "Sonarr";
                  url = "https://sonarr.${baseDomain}";
                  icon = "/assets/sonarr.svg";
                }
                {
                  title = "Radarr";
                  url = "https://radarr.${baseDomain}";
                  icon = "/assets/radarr.svg";
                }
                {
                  title = "Lidarr";
                  url = "https://lidarr.${baseDomain}";
                  icon = "/assets/lidarr.svg";
                }
                {
                  title = "Prowlarr";
                  url = "https://prowlarr.${baseDomain}";
                  icon = "/assets/prowlarr.svg";
                }
                {
                  title = "Bazarr";
                  url = "https://bazarr.${baseDomain}";
                  icon = "/assets/bazarr.svg";
                }
              ];
            }
            {
              type = "monitor";
              cache = "1m";
              title = "Monitoring";
              sites = [
                {
                  title = "Gatus";
                  url = "https://status.${baseDomain}";
                  icon = "/assets/gatus.svg";
                }
                {
                  title = "Grafana";
                  url = "https://grafana.${baseDomain}";
                  icon = "/assets/grafana.svg";
                }
                {
                  title = "Prometheus";
                  url = "https://metrics.${baseDomain}";
                  icon = "/assets/prometheus.svg";
                }
              ];
            }
            {
              type = "monitor";
              cache = "1m";
              title = "Misc";
              sites = [
                {
                  title = "3D Printer";
                  url = "https://sovol.${baseDomain}";
                  icon = "/assets/mainsail.svg";
                }
                {
                  title = "Miniflux";
                  url = "https://miniflux.${baseDomain}";
                  icon = "/assets/miniflux-light.svg";
                }
                {
                  title = "Readeck";
                  url = "https://readeck.${baseDomain}";
                  icon = "/assets/readeck.svg";
                }
                {
                  title = "Scanservjs";
                  url = "https://scan.${baseDomain}";
                  icon = "/assets/printer.svg";
                }
              ];
            }
            {
              type = "monitor";
              cache = "1m";
              title = "Network";
              sites = [
                {
                  title = "Gateway";
                  url = "http://${net.gateway}";
                  icon = "/assets/tp-link.svg";
                }
                {
                  title = "Pangolin";
                  url = "https://pangolin.${baseDomain}";
                  icon = "/assets/pangolin.svg";
                }
              ];
            }
          ];
        }
      ];
    }
  ];
}
