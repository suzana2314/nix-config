{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.oil.enable = lib.mkEnableOption "enable oil module";
  };

  config = lib.mkIf config.nixvim-config.plugins.oil.enable {
    programs.nixvim = {
      plugins = {
        oil = {
          enable = true;
          settings = {
            default_file_explorer = true;
            skip_confirm_for_simple_edits = true;
            delete_to_trash = true;
            view_options = {
              show_hidden = true;
            };
            float = {
              padding = 4;
            };
          };
        };
      };
      keymaps = [
        {
          action = "<cmd>Oil --float<CR>";
          key = "<leader>o";
        }
      ];
    };
  };
}
