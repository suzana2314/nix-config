{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (config) homelab;
  service = "glance";
  cfg = homelab.services.${service};
  networkCfg = inputs.nix-secrets.networking;
in
# TODO setup the services to be automatically configured if the modules are enabled
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 5678;
    };
    apiToken = lib.mkOption {
      type = lib.types.path;
      description = "The path to the apiToken of the remote machine";
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      package = pkgs.unstable.glance;
      settings = {
        server = {
          host = "localhost";
          port = cfg.port;
          proxied = true;
        };
        theme = {
          # gruvbox hard
          "background-color" = "195 6 12";
          "primary-color" = "43 59 81";
          "positive-color" = "61 66 44";
          "negative-color" = "6 96 59";
        };
        branding = {
          "custom-footer" = "<p>Powered by <a href=\"https://github.com/glanceapp/glance\">Glance</a></p>";
          "logo-text" = "S";
        };
        pages = [
          {
            name = "Main";
            columns = [
              {
                size = "small";
                widgets = [
                  {
                    type = "calendar";
                  }
                  {
                    type = "server-stats";
                    servers = [
                      {
                        type = "local";
                      }
                      {
                        type = "remote";
                        url = "https://byrgenwerth-glance.${homelab.baseDomain}";
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
                        type = "reddit";
                        subreddit = "portugal";
                      }
                      {
                        type = "lobsters";
                        sort-by = "hot";
                        limit = 15;
                        collapse-after = 5;
                      }
                      {
                        type = "hacker-news";
                        limit = 15;
                        collapse-after = 5;
                      }
                    ];
                  }
                  {
                    type = "monitor";
                    cache = "1m";
                    title = "Services";
                    sites = [
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
                        title = "Immich";
                        url = "https://immich.${config.homelab.baseDomain}";
                        icon = "di:immich";
                      }
                      {
                        title = "Home Assistant";
                        url = "https://homeassistant.${config.homelab.baseDomain}";
                        icon = "di:home-assistant";
                      }
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
                    ];
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
                        icon = "https://github.com/pablozg/freeds/wiki/images/logo.png";
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
                        title = "Uptime Kuma";
                        url = "https://kuma.${config.homelab.baseDomain}";
                        icon = "di:uptime-kuma";
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
                      {
                        title = "Adguard Main";
                        url = "https://dns.${config.homelab.baseDomain}";
                        icon = "di:adguard-home";
                      }
                      {
                        title = "Adguard Backup";
                        url = "http://${networkCfg.services.adguardbak}";
                        icon = "di:adguard-home";
                      }
                    ];
                  }
                ];
              }
            ];
          }
        ];
      };
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:5678
      '';
    };
  };
}
