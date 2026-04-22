local telescope = require('telescope')
local actions = require('telescope.actions')
local keymap = vim.keymap.set

local layout_config = {
  vertical = {
    width = function(_, max_columns)
      return math.floor(max_columns * 0.99)
    end,
    height = function(_, _, max_lines)
      return math.floor(max_lines * 0.99)
    end,
    prompt_position = 'bottom',
    preview_cutoff = 0,
  },
}

telescope.setup {
  defaults = {
    path_display = {
      'truncate',
    },
    layout_strategy = 'vertical',
    layout_config = layout_config,
    mappings = {
      n = {
        q = actions.close,
        ["<C-v>"] = actions.select_vertical,
        ["<C-s>"] = actions.select_horizontal,
      },
      i = {
        ["<C-v>"] = actions.select_vertical,
        ["<C-s>"] = actions.select_horizontal,
      },
    },
    preview = {
      treesitter = true,
    },
    history = {
      path = vim.fn.stdpath('data') .. '/telescope_history.sqlite3',
      limit = 1000,
    },
    color_devicons = true,
    set_env = { ['COLORTERM'] = 'truecolor' },
    prompt_prefix = ' search ',
    selection_caret = '  ',
    entry_prefix = '  ',
    initial_mode = 'insert',
    vimgrep_arguments = {
      'rg',
      '-L',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
    },
  },
}

-- mappings
keymap('n', '<leader>ff', "<cmd>Telescope find_files<CR>")
keymap('n', '<leader>fg', "<cmd>Telescope live_grep<CR>")
keymap('n', '<leader>fb', "<cmd>Telescope buffers<CR>")
