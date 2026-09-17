{ pkgs, lib }:
let
  dasboardIcons = pkgs.fetchFromGitHub {
    owner = "homarr-labs";
    repo = "dashboard-icons";
    rev = "ce550a844bad92ea19b5926cb887285c46bac01a";
    sha256 = "sha256-WxXaZJbxlxQ+LpyUxj+pNu6CSTCOpM88OJS07/oYUEY=";
  };

  icons = {
    "miniflux-light.svg" = "svg/miniflux-light.svg";
    "home-assistant.svg" = "svg/home-assistant.svg";
    "jellyfin.svg" = "svg/jellyfin.svg";
    "navidrome.png" = "png/navidrome.png";
    "immich.svg" = "svg/immich.svg";
    "frigate-light.svg" = "svg/frigate-light.svg";
    "espressif.svg" = "svg/espressif.svg";
    "seerr.svg" = "svg/seerr.svg";
    "qbittorrent.svg" = "svg/qbittorrent.svg";
    "sonarr.svg" = "svg/sonarr.svg";
    "radarr.svg" = "svg/radarr.svg";
    "prowlarr.svg" = "svg/prowlarr.svg";
    "bazarr.svg" = "svg/bazarr.svg";
    "gatus.svg" = "svg/gatus.svg";
    "grafana.svg" = "svg/grafana.svg";
    "prometheus.svg" = "svg/prometheus.svg";
    "mainsail.svg" = "svg/mainsail.svg";
    "endurain.svg" = "svg/endurain.svg";
    "readeck.svg" = "svg/readeck.svg";
    "printer.svg" = "svg/printer.svg";
    "tp-link.svg" = "svg/tp-link.svg";
    "pangolin.svg" = "svg/pangolin.svg";
  };
in
pkgs.runCommand "glance-dashboard-icons" { } (
  "mkdir -p $out\n"
  + lib.concatStringsSep "\n" (
    lib.mapAttrsToList (dest: src: "cp ${dasboardIcons}/${src} $out/${dest}") icons
  )
)
