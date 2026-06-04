{ lib, ... }:
let
  mkFontOption = kind: {
    name = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Family name for ${kind} font profile";
      example = "Iosevka Nerd Font";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = null;
      description = "Package for ${kind} font profile";
      example = "pkgs.iosevka";
    };
  };
in
{
  options.scheme = {
    wallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to the wallpaper image";
    };
    theme = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Base16 color theme name";
    };
    polarity = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Polarity can be either dark or light";
    };
    fonts = {
      monospace = lib.mkOption {
        type = lib.types.submodule { options = mkFontOption "monospace"; };
        default = { };
        description = "Monospace font profile";
      };
      sansSerif = lib.mkOption {
        type = lib.types.submodule { options = mkFontOption "sans-serif"; };
        default = { };
        description = "sans-serif font profile";
      };
    };
  };
}
