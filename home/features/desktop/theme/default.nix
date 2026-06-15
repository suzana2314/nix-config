{
  inputs,
  pkgs,
  config,
  ...
}:
let
  inherit (config.scheme)
    theme
    wallpaper
    polarity
    cursor
    fonts
    icons
    ;
  resolvedWallpaper =
    if wallpaper.url != null then
      pkgs.fetchurl {
        url = wallpaper.url;
        hash = wallpaper.hash;
      }
    else
      wallpaper.path;
in
{
  imports = [
    inputs.stylix.homeModules.stylix
  ];
  stylix = {
    enable = true;
    autoEnable = false;
    enableReleaseChecks = false;
    base16Scheme = theme;
    polarity = polarity;
    image = resolvedWallpaper;
    cursor = cursor;
    icons = {
      enable = true;
      dark = icons.dark;
      light = icons.light;
      package = icons.package;
    };
    fonts = {
      monospace = {
        package = fonts.monospace.package;
        name = fonts.monospace.name;
      };
      sansSerif = {
        package = fonts.sansSerif.package;
        name = fonts.sansSerif.name;
      };
      serif = config.stylix.fonts.sansSerif;
    };
    targets = {
      font-packages.enable = true;
      gtk = {
        enable = true;
        fonts.enable = false;
      };
      qt = {
        enable = true;
        standardDialogs = "xdgdesktopportal";
      };
      gnome = {
        enable = true;
        fonts.enable = false;
      };
    };
  };

  gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
}
