{ lib, config, ... }:
let
  inherit (config) wallpaper;
  # applies the same wallpaper to all monitors
  wallpaperList = lib.concatMapStringsSep "\n" (monitor: "${monitor.name},${wallpaper}") (
    lib.filter (m: m.enabled) config.monitors
  );
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ wallpaper ];
      wallpaper = lib.splitString "\n" wallpaperList;
    };
  };
}
