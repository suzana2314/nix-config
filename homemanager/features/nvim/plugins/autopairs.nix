{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.autopairs.enable = lib.mkEnableOption "enable autopairs module";
  };

  config = lib.mkIf config.nixvim-config.plugins.autopairs.enable {
    programs.nixvim = {
      plugins = {
        nvim-autopairs = {
          enable = true;
          settings = {
            check_ts = true;
          };
        };
      };
    };
  };
}
