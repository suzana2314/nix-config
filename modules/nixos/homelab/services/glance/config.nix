{
  baseDomain,
  cfg,
  net,
}:
let
  makeUrl = sd: "https://${sd}.${baseDomain}";
in
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
              url = makeUrl "miniflux";
              icon = "/assets/miniflux-light.svg";
            }
            {
              title = "Home Assistant";
              url = makeUrl "homeassistant";
              icon = "/assets/home-assistant.svg";
            }
            {
              title = "Jellyfin";
              url = makeUrl "jellyfin";
              icon = "/assets/jellyfin.svg";
            }
            {
              title = "Navidrome";
              url = makeUrl "navidrome";
              icon = "/assets/navidrome.png";
            }
            {
              title = "Immich";
              url = makeUrl "immich";
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
                  url = makeUrl "byrgenwerth-glance";
                  token = {
                    _secret = cfg.apiToken;
                  };
                }
                {
                  type = "remote";
                  url = makeUrl "mensis-glance";
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
              type = "group";
              widgets = [
                {
                  type = "hacker-news";
                  limit = 15;
                  collapse-after = 6;
                }
                {
                  type = "lobsters";
                  limit = 15;
                  collapse-after = 6;
                }
              ];
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
              title = "Main";
              sites = [
                {
                  title = "Home Assistant";
                  url = makeUrl "homeassistant";
                  icon = "/assets/home-assistant.svg";
                }
                {
                  title = "Immich";
                  url = makeUrl "immich";
                  icon = "/assets/immich.svg";
                }
                {
                  title = "Navidrome";
                  url = makeUrl "navidrome";
                  icon = "/assets/navidrome.png";
                }
                {
                  title = "Miniflux";
                  url = makeUrl "miniflux";
                  icon = "/assets/miniflux-light.svg";
                }
                {
                  title = "Readeck";
                  url = makeUrl "readeck";
                  icon = "/assets/readeck.svg";
                }
              ];
            }
            {
              type = "monitor";
              cache = "1m";
              title = "Media";
              sites = [
                {
                  title = "Jellyfin";
                  url = makeUrl "jellyfin";
                  icon = "/assets/jellyfin.svg";
                }
                {
                  title = "Seerr";
                  url = makeUrl "seerr";
                  icon = "/assets/seerr.svg";
                }
                {
                  title = "qBitTorrent";
                  url = makeUrl "qbittorrent";
                  icon = "/assets/qbittorrent.svg";
                }
                {
                  title = "slskd";
                  url = makeUrl "slskd";
                  icon = "/assets/slskd.svg";
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
                  url = makeUrl "sonarr";
                  icon = "/assets/sonarr.svg";
                }
                {
                  title = "Radarr";
                  url = makeUrl "radarr";
                  icon = "/assets/radarr.svg";
                }
                {
                  title = "Prowlarr";
                  url = makeUrl "prowlarr";
                  icon = "/assets/prowlarr.svg";
                }
                {
                  title = "Bazarr";
                  url = makeUrl "bazarr";
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
                  url = makeUrl "status";
                  icon = "/assets/gatus.svg";
                }
                {
                  title = "Grafana";
                  url = makeUrl "grafana";
                  icon = "/assets/grafana.svg";
                }
                {
                  title = "Prometheus";
                  url = makeUrl "metrics";
                  icon = "/assets/prometheus.svg";
                }
                {
                  title = "Alertmanager";
                  url = makeUrl "alerts";
                  icon = "/assets/alertmanager-dark.svg";
                }
                {
                  title = "Gotify";
                  url = makeUrl "gtfy";
                  icon = "/assets/gotify.svg";
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
                  url = makeUrl "sovol";
                  icon = "/assets/mainsail.svg";
                }
                {
                  title = "Endurain";
                  url = makeUrl "endurain";
                  icon = "/assets/endurain.svg";
                }
                {
                  title = "Scan";
                  url = makeUrl "scan";
                  icon = "/assets/printer.svg";
                }
                {
                  title = "Frigate";
                  url = makeUrl "frigate";
                  icon = "/assets/frigate-light.svg";
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
                  url = makeUrl "pangolin";
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
