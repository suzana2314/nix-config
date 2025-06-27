{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "mediaStack";
  cfg = homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable the linux iso download tools";
    };

    mediaDir = lib.mkOption {
      type = lib.types.str;
      default = "/storage/data";
    };

    gluetun = {
      enable = lib.mkEnableOption {
        description = "VPN tunneling for qbittorrent";
      };

      vpnProvider = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Your vpn provider (mullvad, proton...)";
      };

      vpnCities = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "The cities or city where the vpn server you are connecting to is";
      };

      vpnCredentialsFile = lib.mkOption {
        type = lib.types.path;
        default = "/dev/null";
        description = "Path to file with WireGuard credentials";
      };
    };

  };

  config = lib.mkIf cfg.enable {

    # Arrs need this...
    nixpkgs.config.permittedInsecurePackages = [
      "dotnet-sdk-6.0.428"
      "aspnetcore-runtime-6.0.36"
    ];

    users = {
      groups = {
        # Primary groups
        streamer.gid = 6000;
        downloader.gid = 6001;
        media.gid = 6002;
      };

      users = {
        streamer = {
          isSystemUser = true;
          group = "streamer";
          uid = 6000;
        };
        downloader = {
          isSystemUser = true;
          group = "downloader";
          uid = 6001;
        };
        mediamanager = {
          isSystemUser = true;
          group = "media";
          uid = 6002;
        };
      };
    };

    systemd.tmpfiles.rules = [
      # Base directory
      "d ${cfg.mediaDir} 0755 root root -"

      "d ${cfg.mediaDir}/media 0775 streamer media -"
      "d ${cfg.mediaDir}/media/movies 0775 streamer media -"
      "d ${cfg.mediaDir}/media/tv 0775 streamer media -"

      "d ${cfg.mediaDir}/torrents 2775 downloader media -"
      "d ${cfg.mediaDir}/torrents/movies 2775 downloader media -"
      "d ${cfg.mediaDir}/torrents/tv 2775 downloader media -"

      # default for podman services
      "d /var/lib/gluetun 0755 downloader downloader -"
      "d /var/lib/qbittorrent/config 0755 downloader downloader -"
    ];

    services = {
      bazarr = {
        enable = true;
        user = "mediamanager";
        group = "media";
      };
      radarr = {
        enable = true;
        user = "mediamanager";
        group = "media";
      };
      sonarr = {
        enable = true;
        user = "mediamanager";
        group = "media";
      };

      jellyfin = {
        enable = true;
        user = "streamer";
        group = "media";
      };

      jellyseerr = {
        enable = true;
      };

      prowlarr.enable = true;
    };

    virtualisation.oci-containers = {
      containers = {
        gluetun = lib.mkIf cfg.gluetun.enable {
          image = "qmcgaw/gluetun:latest";
          autoStart = true;
          extraOptions = [
            "--pull=newer"
            "--cap-add=NET_ADMIN"
            "--device=/dev/net/tun:/dev/net/tun"
          ];
          environmentFiles = [ cfg.gluetun.vpnCredentialsFile ];
          environment = {
            VPN_TYPE = "wireguard";
            VPN_SERVICE_PROVIDER = cfg.gluetun.vpnProvider;
            TZ = homelab.timeZone;
            SERVER_CITIES = cfg.gluetun.vpnCities;
            UPDATER_PERIOD = "24h";
            OWNED_ONLY = "yes";
          };
          ports = [
            "6881:6881"
            "6881:6881/udp"
            "8080:8080"
          ];
          volumes = [
            "/var/lib/gluetun:/gluetun"
          ];
        };

        qbittorrent = {
          image = "lscr.io/linuxserver/qbittorrent:latest";
          autoStart = true;
          dependsOn = lib.mkIf cfg.gluetun.enable [ "gluetun" ];
          extraOptions = lib.mkIf cfg.gluetun.enable [ "--network=container:gluetun" ];
          ports = lib.mkIf (!cfg.gluetun.enable) [
            "8080:8080"
            "6881:6881"
            "6881:6881/udp"
          ];
          volumes = [
            "${cfg.mediaDir}/torrents:/data/torrents"
            "/var/lib/qbittorrent/config:/config"
          ];
          environment = {
            TZ = homelab.timeZone;
            PUID = "6001"; # downloader
            PGID = "6001";
            UMASK = "0002";
            WEBUI_PORT = "8080";
          };
        };
      };
    };

    services.caddy.virtualHosts = {
      "bazarr.${homelab.baseDomain}" = {
        useACMEHost = homelab.baseDomain;
        extraConfig = "reverse_proxy http://127.0.0.1:6767";
      };
      "jellyfin.${homelab.baseDomain}" = {
        useACMEHost = homelab.baseDomain;
        extraConfig = "reverse_proxy http://127.0.0.1:8096";
      };
      "jellyseerr.${homelab.baseDomain}" = {
        useACMEHost = homelab.baseDomain;
        extraConfig = "reverse_proxy http://127.0.0.1:5055";
      };
      "prowlarr.${homelab.baseDomain}" = {
        useACMEHost = homelab.baseDomain;
        extraConfig = "reverse_proxy http://127.0.0.1:9696";
      };
      "radarr.${homelab.baseDomain}" = {
        useACMEHost = homelab.baseDomain;
        extraConfig = "reverse_proxy http://127.0.0.1:7878";
      };
      "sonarr.${homelab.baseDomain}" = {
        useACMEHost = homelab.baseDomain;
        extraConfig = "reverse_proxy http://127.0.0.1:8989";
      };
      "qbittorrent.${homelab.baseDomain}" = {
        useACMEHost = homelab.baseDomain;
        extraConfig = "reverse_proxy http://127.0.0.1:8080";
      };
    };
  };
}
