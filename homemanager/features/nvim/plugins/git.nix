{ config, lib, ... }: {

  options = {
    nixvim-config.plugins.git.enable = lib.mkEnableOption "enables  neovim git modules";
  };

  config = lib.mkIf config.nixvim-config.plugins.git.enable {
    programs.nixvim = {
      plugins = {
        gitsigns = {
          enable = true;
        };
        neogit = {
          enable = true;
        };
      };

      keymaps = [
        {
          mode = "n";
          key = "<leader>gg";
          action = "<cmd>Neogit<CR>";
        }
      ];
    };
  };
}
