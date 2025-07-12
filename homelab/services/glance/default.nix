{ inputs, lib, config, pkgs, ... }:
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
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      package = pkgs.unstable.glance;
      settings = {
        server.port = 5678;
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
                    ];
                  }
                  {
                    type = "custom-api";
                    title = "Random Fact";
                    cache = "3h";
                    url = "https://uselessfacts.jsph.pl/api/v2/facts/random";
                    template = "<p class=\"size-h4 color-paragraph\">{{ .JSON.String \"text\" }}</p>";
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
                        url = "http://sovol.${config.homelab.baseDomain}";
                        icon = "di:mainsail";
                      }
                      {
                        title = "AdGuard";
                        url = "http://${networkCfg.services.adguard}";
                        icon = "di:adguard-home";
                      }
                    ];
                  }
                  {
                    type = "videos";
                    channels = [
                      "UCsBjURrPoezykLs9EqgamOA" # fireship
                      "UCgdTVe88YVSrOZ9qKumhULQ" # hardware haven
                      "UCiczXOhGpvoQGhOL16EZiTg" # cnc kitchen
                      "UCpXwMqnXfJzazKS5fJ8nrVw" # shiey
                      "UC2avWDLN1EI3r1RZ_dlSxCw" # integza
                      "UC_zBdZ0_H_jn41FDRG7q4Tw" # vimjoyer
                      "UCb6kgJyChDCR4aK0-GEsZKQ" # chris borge
                      "UCR-DXc1voovS8nhAvccRZhg" # jeff geerling
                      "UCsnGwSIHyoYN0kiINAGUKxg" # wolfgang
                      "UCAbAsEZ-0LccTNbl8r-3EaQ" # scott yj
                      "UC67gfx2Fg7K2NSHqoENVgwA" # tom stanton
                    ];
                  }
                ];
              }
              {
                size = "small";
                widgets = [
                  {
                    type = "weather";
                    location = "Lisbon, Portugal";
                  }
                  {
                    type = "group";
                    widgets = [
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
                    type = "search";
                    autofocus = true;
                  }
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
                        alt-status-codes = [ 403 401 ];
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
                    title = "Network";
                    sites = [
                      {
                        title = "Gateway";
                        url = "http://${networkCfg.subnets.default.gateway}";
                        icon = "di:tp-link";
                      }
                      {
                        title = "Adguard Main";
                        url = "http://${networkCfg.services.adguard}";
                        icon = "di:adguard-home";
                      }
                      {
                        title = "Adguard Backup";
                        url = "http://${networkCfg.services.adguardbak}";
                        icon = "di:adguard-home";
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
                        title = "Gotify";
                        url = "https://gotify.${config.homelab.baseDomain}";
                        icon = "di:gotify";
                      }
                      {
                        title = "Uptime Kuma";
                        url = "https://kuma.${config.homelab.baseDomain}";
                        icon = "di:uptime-kuma";
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

    # FIXME I think this was solved: https://github.com/NixOS/nixpkgs/pull/395859
    systemd.services.glance = {
      serviceConfig = {
        ProcSubset = lib.mkForce "all";
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
