{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.programs.whipper;
  iniFormat = pkgs.formats.ini { };
in
{
  options.programs.whipper = {
    enable = lib.mkEnableOption "whipper";
    package = lib.mkPackageOption pkgs "whipper" { };

    settings = lib.mkOption {
      type = iniFormat.type;
      default = { };
      example = lib.literalExpression ''
        {
          main = {
            path_filter_dot = true;
            path_filter_posix = true;
            path_filter_vfat = false;
            path_filter_whitespace = false;
            path_filter_printable = false;
          };

          musicbrainz = {
            server = "https://musicbrainz.org";
          };

          "drive:HL-20" = {
            defeats_cache = true;
            read_offset = 6;
          };

          whipper = {
            eject = "always";
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."whipper/whipper.conf" = {
      source = iniFormat.generate "whipper.conf" cfg.settings;
    };
  };
}
