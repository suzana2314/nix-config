require'nvim-treesitter.configs'.setup {
  ensure_installed = {},
  sync_install = false,
  auto_install = false,
  ignore_install = {},
  modules = {},
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
