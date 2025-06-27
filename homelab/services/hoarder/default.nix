{ config, lib, ... }:
let
  service = "hoarder";
  inherit (config) homelab;
  cfg = homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable Hoarder";
    };
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
      description = "Directory where Hoarder data will be stored";
    };
    meilisearchDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}-meilisearch";
      description = "Directory where Meilisearch data will be stored";
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = "hoarder";
      description = "User under which the containers will run";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "hoarder";
      description = "Group under which the containers will run";
    };
    uid = lib.mkOption {
      type = lib.types.int;
      default = 1001;
      description = "UID for the hoarder user";
    };
    gid = lib.mkOption {
      type = lib.types.int;
      default = 1002;
      description = "GID for the hoarder group";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
      description = "URL where Hoarder will be accessible";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3568;
      description = "Port where Hoarder will listen";
    };
    version = lib.mkOption {
      type = lib.types.str;
      default = "release";
      description = "Version of Hoarder to use";
    };
    openaiApiKey = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "OpenAI API key for Hoarder";
    };
    nextAuthSecret = lib.mkOption {
      type = lib.types.str;
      description = "Random string for NextAuth secret. Generate with: openssl rand -base64 36";
    };
    meilisearchMasterKey = lib.mkOption {
      type = lib.types.str;
      description = "Random string for Meilisearch master key. Generate with: openssl rand -base64 36";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      inherit (cfg) uid group;
    };

    users.groups.${cfg.group} = {
      inherit (cfg) gid;
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.meilisearchDir} 0750 ${cfg.user} ${cfg.group} -"
    ];

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };

    virtualisation = {
      oci-containers = {
        containers = {
          hoarder = {
            image = "ghcr.io/hoarder-app/hoarder:${cfg.version}";
            autoStart = true;
            environment = {
              MEILI_ADDR = "http://hoarder-meilisearch:7700";
              BROWSER_WEB_URL = "http://hoarder-chrome:9222";
              DATA_DIR = "/data";
              MEILI_MASTER_KEY = cfg.meilisearchMasterKey;
              OPENAI_API_KEY = cfg.openaiApiKey;
              NEXTAUTH_SECRET = cfg.nextAuthSecret;
              NEXTAUTH_URL = "https://${cfg.url}";
            };
            volumes = [
              "${cfg.dataDir}:/data"
            ];
            ports = [
              "${toString cfg.port}:3000"
            ];
            dependsOn = [
              "hoarder-chrome"
              "hoarder-meilisearch"
            ];
            extraOptions = [
              "--network=podman"
            ];
          };

          hoarder-chrome = {
            image = "gcr.io/zenika-hub/alpine-chrome:123";
            autoStart = true;
            user = "${toString cfg.uid}:${toString cfg.gid}";
            cmd = [
              "--no-sandbox"
              "--disable-gpu"
              "--disable-dev-shm-usage"
              "--remote-debugging-address=0.0.0.0"
              "--remote-debugging-port=9222"
              "--hide-scrollbars"
            ];
            extraOptions = [
              "--network=podman"
            ];
          };

          hoarder-meilisearch = {
            image = "getmeili/meilisearch:v1.11.1";
            autoStart = true;
            user = "${toString cfg.uid}:${toString cfg.gid}";
            environment = {
              MEILI_NO_ANALYTICS = "true";
              MEILI_MASTER_KEY = cfg.meilisearchMasterKey;
            };
            volumes = [
              "${cfg.meilisearchDir}:/meili_data"
            ];
            extraOptions = [
              "--network=podman"
            ];
          };
        };
      };
    };
  };
}
