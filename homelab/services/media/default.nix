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

      "d ${cfg.mediaDir}/torrents 0755 ${homelab.user} ${homelab.group} -"
      "d ${cfg.mediaDir}/torrents/movies 0755 ${homelab.user} ${homelab.group} -"
      "d ${cfg.mediaDir}/torrents/tv 0755 ${homelab.user} ${homelab.group} -"

    ];

    homelab.services = {
      jellyfin.enable = lib.mkDefault true;
      radarr.enable = lib.mkDefault true;
      sonarr.enable = lib.mkDefault true;
      prowlarr.enable = lib.mkDefault true;
      bazarr.enable = lib.mkDefault true;
      jellyseerr.enable = lib.mkDefault true;
      qbittorrent.enable = lib.mkDefault true;
    };
  };

  imports = [
    ./bazarr
    ./radarr
    ./sonarr
    ./prowlarr
    ./jellyfin
    ./jellyseerr
    ./qbittorrent
  ];
}
