{ lib, config, ... }:
let
  inherit (config) wallpaper;
  # applies the same wallpaper to all monitors
  wallpaperList = map (monitor: {
    monitor = monitor.name;
    path = wallpaper;
  }) (lib.filter (m: m.enabled) config.monitors);
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      wallpaper = wallpaperList;
    };
  };
}
