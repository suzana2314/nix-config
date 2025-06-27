{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.nvim-lightbulb.enable = lib.mkEnableOption "enable nvim-lightbulb module";
  };

  config = lib.mkIf config.nixvim-config.plugins.nvim-lightbulb.enable {
    programs.nixvim = {
      plugins = {
        nvim-lightbulb = {
          enable = true;
          settings = {
            autocmd = {
              enabled = true;
              updateTime = 200;
            };
            sign = {
              enabled = true;
              text = "󰌶";
            };
          };
        };
      };
    };
  };
}
