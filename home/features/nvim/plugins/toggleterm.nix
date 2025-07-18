{ config, lib, ... }:
{

  options = {
    nixvim-config.plugins.toggleterm.enable = lib.mkEnableOption "enables toggleterm module";
  };

  config = lib.mkIf config.nixvim-config.plugins.toggleterm.enable {
    programs.nixvim = {
      plugins = {
        toggleterm = {
          enable = true;
          settings = {
            direction = "float";
            autochdir = true;
            open_mapping = "[[<leader>gt]]";
            insert_mappings = false;
            start_in_insert = true;
            float_opts = {
              border = "curved";
            };
          };
        };
      };
    };
  };
}
