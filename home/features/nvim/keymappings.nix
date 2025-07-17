{
  programs.nixvim = {
    globals.mapleader = ";";

    keymaps = [
      # movement
      {
        mode = [ "n" ];
        key = "<C-j>";
        action = "<C-d>";
        options = {
          desc = "Add bind for 1/2 page down";
          noremap = true;
        };
      }

      {
        mode = [ "n" ];
        key = "<C-k>";
        action = "<C-u>";
        options = {
          desc = "Add bind for 1/2 page up";
          noremap = true;
        };
      }

      # search
      {
        mode = [ "n" ];
        key = "<space><space>";
        action = "<cmd>noh<CR>";
        options = {
          desc = "Clear search highlighting";
          noremap = true;
        };
      }

      # Copy to clipboard
      {
        action = "\"+y";
        key = "<leader>y";
      }
    ];
  };
}
