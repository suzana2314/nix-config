{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.web-devicons.enable = lib.mkEnableOption "enable web-devicons module";
  };

  config = lib.mkIf config.nixvim-config.plugins.web-devicons.enable {
    programs.nixvim = {
      plugins = {
        web-devicons = {
          enable = true;
          settings = {
            color_icons = true;
            strict = true;
            variant = "dark";
          };
        };
      };
    };
  };
}
