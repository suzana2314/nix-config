{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf;
  cfg = config.fontProfiles;
  mkFontOption = kind: {
    name = mkOption {
      type = types.str;
      default = null;
      description = "Family name for ${kind} font profile";
      example = "Iosevka Nerd Font";
    };
    package = mkOption {
      type = types.package;
      default = null;
      description = "Package for ${kind} font profile";
      example = "pkgs.iosevka";
    };
    size = mkOption {
      type = types.int;
      default = 12;
      description = "Size in pixels for ${kind} font profile";
      example = "13";
    };
  };
in
{
  options.fontProfiles = {
    enable = mkEnableOption "Wether to enable font profiles";
    monospace = mkFontOption "monospace";
    regular = mkFontOption "regular";
  };
  config = mkIf cfg.enable {
    fonts = {
      fontconfig.enable = true;
    };
    home.packages = [
      cfg.monospace.package
      cfg.regular.package
    ];
  };
}
