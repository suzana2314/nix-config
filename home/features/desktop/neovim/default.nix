{
  pkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      nvim-treesitter
      telescope-nvim
      nvim-lspconfig
      nvim-cmp
      lspkind-nvim
      cmp-nvim-lsp
      cmp-nvim-lsp-signature-help
      cmp-buffer
      cmp-path
      cmp-nvim-lua
      cmp-cmdline
      cmp-cmdline-history
      cmp_luasnip
      luasnip

      # ui
      gruvbox-nvim
      lualine-nvim
      nvim-web-devicons
    ];

    extraConfig = ''
      lua << EOF
      ${builtins.readFile config/options.lua}
      ${builtins.readFile config/mappings.lua}
      ${builtins.readFile config/lsp.lua}
      ${builtins.readFile config/autocmd.lua}
      ${builtins.readFile config/plugins/treesitter.lua}
      ${builtins.readFile config/plugins/telescope.lua}
      ${builtins.readFile config/plugins/completion.lua}
      ${builtins.readFile config/plugins/lualine.lua}
    '';
  };

  home.packages = with pkgs; [
    ripgrep
  ];

}
