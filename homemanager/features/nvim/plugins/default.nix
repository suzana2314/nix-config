{ lib, ... }:
{
  imports = [
    ./lspconfig.nix
    ./telescope.nix
    ./nonels.nix
    ./cmp.nix
    ./telescope.nix
    ./toggleterm.nix
    ./treesitter.nix
    ./git.nix
    ./fidget.nix
    ./lualine.nix
    ./oil.nix
    ./vimtex.nix
    ./autopairs.nix
    ./iluminate.nix
    ./nvim-lightbulb.nix
    ./web-devicons.nix
    ./comment.nix
    ./nvim-jdtls.nix
  ];

  config = {
    nixvim-config.colorschemes.enable = lib.mkDefault true;
    nixvim-config.plugins = {
      # ======================= LSP =======================
      lspconfig.enable = lib.mkDefault true;
      nvim-lightbulb.enable = lib.mkDefault true;
      nvim-jdtls.enable = lib.mkDefault false;
      # ======================= SEARCH =======================
      telescope.enable = lib.mkDefault true;

      # ======================= LINT =======================
      nonels.enable = lib.mkDefault true;

      # ======================= COMPLETION =======================
      cmp.enable = lib.mkDefault true;
      autopairs.enable = lib.mkDefault true;
      comment.enable = lib.mkDefault true;

      # ======================= TERMINAL =======================
      toggleterm.enable = lib.mkDefault true;

      # ======================= LANGUAGES =======================
      treesitter.enable = lib.mkDefault true;
      iluminate.enable = lib.mkDefault true;

      # ======================= NOTIFICATION =======================
      fidget.enable = lib.mkDefault true;

      # ======================= FILES =======================
      oil.enable = lib.mkDefault true;

      # ======================= UI =======================
      web-devicons.enable = lib.mkDefault true;
      lualine.enable = lib.mkDefault true;

      # ======================= MISC =======================
      vimtex.enable = lib.mkDefault false;
    };
  };
}
