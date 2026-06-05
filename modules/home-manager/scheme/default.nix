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
    wallpaper = {
      url = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "URL to fetch wallpaper from";
      };
      hash = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "SHA256 hash of the wallpaper file";
      };
      path = lib.mkOption {
        type = with lib.types; nullOr (coercedTo path (src: "${src}") pathInStore);
        default = null;
        description = "Local path to wallpaper image";
      };
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
    cursor = {
      name = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Name of cursor pack";
      };
      size = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Size of the cursor";
      };
      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
        description = "Cursor package";
      };
    };
    icons = {
      dark = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Name of dark icon theme";
      };
      light = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Name of light icon theme";
      };
      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
        description = "Icon theme package";
      };
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
