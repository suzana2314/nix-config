local o = vim.o
local border = 'rounded'

-- leader
vim.g.mapleader = ';'

-- General
o.showmode = false -- remove the current mode (already in the lualine)
o.number = true    -- display line numbers
o.signcolumn = "number"
o.showmatch = true -- highlight matching parentheses, etc
o.wrap = false
o.swapfile = false
o.linebreak = true -- wrap lines at convenient places
o.hid = true       -- a buffer becomes hidden when abandoned
o.foldenable = true
o.history = 2000
o.nrformats = 'bin,hex' -- 'octal'
o.cmdheight = 1

-- Search
o.incsearch = true          -- searches incrementally
o.hlsearch = true
o.path = vim.o.path .. '**' -- search down into subfolders

-- Identation
o.autoindent = true
o.cindent = true -- automatically indent braces
o.smartindent = true
o.tabstop = 2
o.softtabstop = 2
o.shiftwidth = 2
o.expandtab = true
o.smarttab = true

-- Scrolling
o.scrolloff = 4 -- start scrolling when we are 4 lines away from margins
o.sidescrolloff = 15
o.sidescroll = 1

-- Splits
o.splitright = true
o.splitbelow = true
o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

-- UI
o.termguicolors = true
o.background = 'dark'

require('gruvbox').setup({
  terminal_colors = true,
  italic = {
    strings = false,
    emphasis = false,
    comments = false,
    operators = false,
    folds = false,
  },
  strikethrough = false,
  contrast = "hard",

})
vim.cmd("colorscheme gruvbox")
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' }) -- to remove annoying background on floating windows

-- Diagnostics
vim.diagnostic.config {
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    focusable = false,
    style = 'minimal',
    border = border,
    source = 'if_many',
    header = '',
    prefix = '',
  },
}

-- Netrw

-- syncs the current dir and browsing dir
vim.g.netrw_keepdir = 0

-- hides banner
vim.g.netrw_banner = 0

-- hide dotfiles
vim.g.netrw_list_hide = [[\(^\|\s\s\)\zs\.\S\+]]

-- better copy command
vim.g.netrw_localcopydircmd = 'cp -r'
