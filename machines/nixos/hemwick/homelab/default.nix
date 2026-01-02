{ inputs, config, ... }:
let
  sopsFile = "${builtins.toString inputs.nix-secrets}/sops/${config.networking.hostName}.yaml";
  networkCfg = inputs.nix-secrets.networking;
  hostCfg = networkCfg.subnets.default.hosts.hemwick;
  serviceCfg = networkCfg.services;
in
{
  homelab = {
    enable = true;
    inherit (config.time) timeZone;
    email = inputs.nix-secrets.email.default;
    baseDomain = inputs.nix-secrets.domain;
    cloudflare.dnsCredentialsFile = config.sops.secrets."cloudflare/dnsCredentials".path;
    externalIP = hostCfg.ip;

    motd.enable = true;
    notify-ssh = {
      enable = true;
      credentialsFile = config.sops.secrets."telegram/ssh".path;
    };

    services = {
      enable = true;

      dns = {
        enable = true;
        url = "dns1.${inputs.nix-secrets.domain}";
        dnsMappings = inputs.nix-secrets.dnsMappings;
        dnsRewrites = inputs.nix-secrets.dnsRewrites;
      };

      ddns-updater = {
        enable = true;
        configFile = config.sops.secrets."cloudflare/ddnsCredentials".path;
        notifications = config.sops.secrets."cloudflare/ddnsNotification".path;
      };

      mosquitto = {
        enable = true;
      };

      esphome = {
        enable = true;
        auth = config.sops.secrets.esphome.path;
      };

      homeassistant = {
        enable = true;
        cloudflared = {
          inherit (inputs.nix-secrets) tunnelId;
          credentialsFile = config.sops.secrets."cloudflare/tunnelCredentials".path;
        };
      };

      gree-server.enable = true;

      glance = {
        enable = true;
        apiToken = config.sops.secrets."glance/byrgenwerthApitoken".path;
      };

      extraCaddyHosts = {
        enable = true;
        hosts = {
          sovol = {
            enable = true;
            host = serviceCfg.sovol;
          };
          freeds = {
            enable = true;
            host = serviceCfg.freeds;
          };
        };
      };

      miniflux = {
        enable = true;
        environmentFile = config.sops.secrets."miniflux/environmentFile".path;
      };

      scanservjs.enable = true;

      grafana = {
        enable = true;
      };

      prometheus-node.enable = true;

      prometheus = {
        enable = true;
        scrapeConfigs = [
          {
            job_name = "hosts";
            static_configs = [
              {
                targets = [
                  "hemwick.${config.homelab.baseDomain}"
                  "byrgenwerth.${config.homelab.baseDomain}"
                  "kos.${config.homelab.baseDomain}"
                ];
              }
            ];
            basic_auth = {
              username = "prometheus-oedon";
              password_file = config.sops.secrets."prometheus/hostsPasswordFile".path;
            };
          }
          {
            job_name = "DNS Primary";
            static_configs = [
              {
                targets = [
                  "dns1.${config.homelab.baseDomain}"
                ];
              }
            ];
          }
          {
            job_name = "DNS Secondary";
            static_configs = [
              {
                targets = [
                  "dns2.${config.homelab.baseDomain}"
                ];
              }
            ];
          }
        ];
      };

      newt = {
        enable = true;
        environmentFile = config.sops.secrets."newt/environmentFile".path;
      };

    };
  };

  # secrets for the homelab config
  sops.secrets = {
    "cloudflare/tunnelCredentials" = {
      inherit sopsFile;
    };
    "cloudflare/dnsCredentials" = {
      inherit sopsFile;
      owner = config.users.users.acme.name;
      mode = "0400";
    };
    "cloudflare/ddnsCredentials" = {
      inherit sopsFile;
      owner = config.users.users.ddns-updater.name;
      group = config.users.users.ddns-updater.name;
      mode = "0400";
    };
    "cloudflare/ddnsNotification" = {
      inherit sopsFile;
      owner = config.users.users.ddns-updater.name;
      group = config.users.users.ddns-updater.name;
      mode = "0400";
    };
    esphome = {
      inherit sopsFile;
      owner = config.users.users.esphome.name;
      mode = "0400";
    };
    "telegram/ssh" = {
      inherit sopsFile;
      mode = "0400";
    };
    "glance/byrgenwerthApitoken" = {
      inherit sopsFile;
      mode = "0400";
    };
    "miniflux/environmentFile" = {
      inherit sopsFile;
      mode = "0400";
    };
    "prometheus/hostsPasswordFile" = {
      inherit sopsFile;
      owner = config.users.users.prometheus.name;
      mode = "0400";
    };
    "newt/environmentFile" = {
      inherit sopsFile;
      mode = "0400";
    };
  };
}
