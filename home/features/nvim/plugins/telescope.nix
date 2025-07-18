{
  config,
  lib,
  pkgs,
  ...
}:
{

  options = {
    nixvim-config.plugins.telescope.enable = lib.mkEnableOption "enables telescope module";
  };

  config = lib.mkIf config.nixvim-config.plugins.telescope.enable {
    programs.nixvim = {
      plugins = {
        telescope = {
          enable = true;
          extensions.fzf-native.enable = true;
        };
      };
      keymaps = [
        {
          mode = [ "n" ];
          key = "<leader>ff";
          action = "<cmd>Telescope find_files<CR>";
          options = {
            desc = "find files";
            noremap = true;
          };
        }
        {
          mode = [ "n" ];
          key = "<leader>fg";
          action = "<cmd>Telescope live_grep<CR>";
          options = {
            desc = "live grep";
            noremap = true;
          };
        }
        {
          mode = [ "n" ];
          key = "<leader>fb";
          action = "<cmd>Telescope buffers<CR>";
          options = {
            desc = "buffers";
            noremap = true;
          };
        }
        {
          mode = [ "n" ];
          key = "<leader>fh";
          action = "<cmd>Telescope help_tags<CR>";
          options = {
            desc = "help tags";
            noremap = true;
          };
        }
      ];
    };
    home.packages = with pkgs; [ ripgrep ];
  };
}
