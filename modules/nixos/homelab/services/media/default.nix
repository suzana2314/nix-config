{ config, lib, ... }:
let
  inherit (config) homelab;
  cfg = homelab.services.media;
in
{
  options.homelab.services.media = {
    enable = lib.mkEnableOption {
      description = "Enable the linux iso download tools";
    };
    mediaDir = lib.mkOption {
      type = lib.types.str;
      default = "/storage/data";
    };
    monitoredServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "bazarr"
        "flaresolverr"
        "jellyfin"
        "seerr"
        "navidrome"
        "prowlarr"
        "qbittorrent"
        "slskd"
        "radarr"
        "sonarr"
      ];
    };
    navidromeEnvFile = lib.mkOption {
      type = lib.types.path;
      example = lib.literalExpression ''
        pkgs.writeText "navidrome-env" '''
          ND_LASTFM_APIKEY=abcabc
          ND_LASTFM_SECRET=abcabc
        '''
      '';
    };
    slskdEnvFile = lib.mkOption {
      description = "Environment file with slskd credentials";
      type = lib.types.path;
      example = lib.literalExpression ''
        pkgs.writeText "slskd-env" '''
          SLSKD_PASSWORD=example
          SLSKD_USERNAME=example
        '''
      '';
    };
    torrentingPort = lib.mkOption {
      type = lib.types.port;
    };
    soulseekPort = lib.mkOption {
      type = lib.types.port;
    };
  };

  config = lib.mkIf cfg.enable {

    nixpkgs.config.permittedInsecurePackages = [
      "dotnet-sdk-6.0.428"
      "aspnetcore-runtime-6.0.36"
    ];

    systemd.tmpfiles.rules = [
      "d ${cfg.mediaDir} 0755 ${homelab.user} ${homelab.group} -"
      "d ${cfg.mediaDir}/media 0755 ${homelab.user} ${homelab.group} -"
      "d ${cfg.mediaDir}/media/movies 0755 ${homelab.user} ${homelab.group} -"
      "d ${cfg.mediaDir}/media/tv 0755 ${homelab.user} ${homelab.group} -"
      "d ${cfg.mediaDir}/media/music 0755 ${homelab.user} ${homelab.group} -"
      "d ${cfg.mediaDir}/media/music/.beets 0775 ${homelab.user} ${homelab.group} -"

      "d ${cfg.mediaDir}/torrents 0755 ${homelab.user} ${homelab.group} -"
      "d ${cfg.mediaDir}/torrents/movies 0755 ${homelab.user} ${homelab.group} -"
      "d ${cfg.mediaDir}/torrents/tv 0755 ${homelab.user} ${homelab.group} -"
      "d ${cfg.mediaDir}/torrents/music 0755 ${homelab.user} ${homelab.group} -"
      "d ${cfg.mediaDir}/torrents/music-incomplete 0755 ${homelab.user} ${homelab.group} -"
    ];

    homelab.services = {
      jellyfin.enable = lib.mkDefault true;
      radarr.enable = lib.mkDefault true;
      sonarr.enable = lib.mkDefault true;
      prowlarr.enable = lib.mkDefault true;
      bazarr.enable = lib.mkDefault true;
      seerr.enable = lib.mkDefault true;
      flaresolverr.enable = lib.mkDefault true;
      qbittorrent = {
        enable = lib.mkDefault true;
        inherit (cfg) torrentingPort;
      };
      navidrome = {
        enable = lib.mkDefault true;
        musicDir = "${cfg.mediaDir}/media/music";
        environmentFile = cfg.navidromeEnvFile;
      };
      slskd = {
        enable = lib.mkDefault true;
        inherit (cfg) soulseekPort;
        environmentFile = cfg.slskdEnvFile;
        musicDir = "${cfg.mediaDir}/media/music";
        downloadDir = "${cfg.mediaDir}/torrents/music";
        incompleteDownloadDir = "${cfg.mediaDir}/torrents/music-incomplete";
      };
    };
  };

  imports = [
    ./bazarr
    ./radarr
    ./sonarr
    ./prowlarr
    ./jellyfin
    ./seerr
    ./qbittorrent
    ./navidrome
    ./flaresolverr
    ./slskd
  ];
}
