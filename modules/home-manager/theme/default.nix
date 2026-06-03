{ lib, ... }:
{
  options.wallpaper = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = ''
      The path to the image for the wallpaper
    '';
  };
  options.colorTheme = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = ''
      Base16 color theme
    '';
  };
}
