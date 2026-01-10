{
  config,
  cfg,
  networkCfg,
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
              url = "https://miniflux.${config.homelab.baseDomain}";
              icon = "di:miniflux-light";
            }
            {
              title = "Home Assistant";
              url = "https://homeassistant.${config.homelab.baseDomain}";
              icon = "di:home-assistant";
            }
            {
              title = "Jellyfin";
              url = "https://jellyfin.${config.homelab.baseDomain}";
              icon = "di:jellyfin";
            }
            {
              title = "Navidrome";
              url = "https://navidrome.${config.homelab.baseDomain}";
              icon = "di:navidrome";
            }
            {
              title = "Immich";
              url = "https://immich.${config.homelab.baseDomain}";
              icon = "di:immich";
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
                  url = "https://byrgenwerth-glance.${config.homelab.baseDomain}";
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
                  url = "https://homeassistant.${config.homelab.baseDomain}";
                  icon = "di:home-assistant";
                }
                {
                  title = "ESPHome";
                  url = "https://esphome.${config.homelab.baseDomain}";
                  icon = "di:esphome";
                }
                {
                  title = "Frigate";
                  url = "https://frigate.${config.homelab.baseDomain}";
                  icon = "di:frigate-light";
                }
                {
                  title = "FreeDS";
                  url = "http://freeds.${config.homelab.baseDomain}";
                  icon = "/assets/freeds_logo.png";
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
                  url = "https://immich.${config.homelab.baseDomain}";
                  icon = "di:immich";
                }
                {
                  title = "Jellyfin";
                  url = "https://jellyfin.${config.homelab.baseDomain}";
                  icon = "di:jellyfin";
                }
                {
                  title = "Jellyseerr";
                  url = "https://jellyseerr.${config.homelab.baseDomain}";
                  icon = "di:jellyseerr";
                }
                {
                  title = "Navidrome";
                  url = "https://navidrome.${config.homelab.baseDomain}";
                  icon = "di:navidrome";
                }
                {
                  title = "qBitTorrent";
                  url = "https://qbittorrent.${config.homelab.baseDomain}";
                  icon = "di:qbittorrent";
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
                  url = "https://sonarr.${config.homelab.baseDomain}";
                  icon = "di:sonarr";
                }
                {
                  title = "Radarr";
                  url = "https://radarr.${config.homelab.baseDomain}";
                  icon = "di:radarr";
                }
                {
                  title = "Lidarr";
                  url = "https://lidarr.${config.homelab.baseDomain}";
                  icon = "di:lidarr";
                }
                {
                  title = "Prowlarr";
                  url = "https://prowlarr.${config.homelab.baseDomain}";
                  icon = "di:prowlarr";
                }
                {
                  title = "Bazarr";
                  url = "https://bazarr.${config.homelab.baseDomain}";
                  icon = "di:bazarr";
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
                  url = "https://status.${config.homelab.baseDomain}";
                  icon = "di:gatus";
                }
                {
                  title = "Grafana";
                  url = "https://grafana.${config.homelab.baseDomain}";
                  icon = "di:grafana";
                }
                {
                  title = "Prometheus";
                  url = "https://metrics.${config.homelab.baseDomain}";
                  icon = "di:prometheus";
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
                  url = "https://sovol.${config.homelab.baseDomain}";
                  icon = "di:mainsail";
                }
                {
                  title = "Miniflux";
                  url = "https://miniflux.${config.homelab.baseDomain}";
                  icon = "di:miniflux-light";
                }
                {
                  title = "Scanservjs";
                  url = "https://scan.${config.homelab.baseDomain}";
                  icon = "di:printer";
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
                  url = "http://${networkCfg.subnets.default.gateway}";
                  icon = "di:tp-link";
                }
                {
                  title = "Pangolin";
                  url = "https://pangolin.${config.homelab.baseDomain}";
                  icon = "di:pangolin";
                }
              ];
            }
          ];
        }
      ];
    }
  ];
}
