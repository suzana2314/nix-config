require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  }
}
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'

