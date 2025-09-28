{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.neo-tree.enable = lib.mkEnableOption "enable neo-tree module";
  };

  config = lib.mkIf config.nixvim-config.plugins.neo-tree.enable {
    programs.nixvim = {
      plugins = {
        neo-tree = {
          enable = true;
        };
      };
      keymaps = [
        {
          action = "<cmd>Neotree toggle<CR>";
          key = "<leader>o";
        }
      ];
    };
  };
}
