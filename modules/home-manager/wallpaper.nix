{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.wallpaper = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = ''
      The path to the image for the wallpaper
    '';
  };

}
