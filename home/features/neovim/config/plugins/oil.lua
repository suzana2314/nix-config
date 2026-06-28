local keymap = vim.keymap.set

require("oil").setup({
  default_file_explorer = true,
  skip_confirm_for_simple_edits = true,
  keymaps = {
    ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
    ["<C-v>"] = { "actions.select", opts = { vertical = true } },
  },
})

keymap('n', '<leader>e', '<cmd>Oil --float<CR>')
