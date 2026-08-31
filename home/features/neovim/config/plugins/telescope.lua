local telescope = require("telescope")
local telescope_builtin = require("telescope.builtin")
local telescope_actions = require("telescope.actions")
local telescope_themes = require("telescope.themes")
local keymap = vim.keymap.set


local borderchars = {
  center = {
    prompt = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    results = { "─", "│", "─", "│", "╭", "╮", "┤", "├" },
  },
  horizontal = {
    prompt = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
    results = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
    preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
  },
}

local function pct_layout(fraction)
  return {
    width = function(_, max_columns) return math.floor(max_columns * fraction) end,
    height = function(_, _, max_lines) return math.floor(max_lines * fraction) end,
  }
end

local popup_list_base = {
  border = true,
  preview = false,
  prompt_title = false,
  results_title = false,
  sorting_strategy = "descending",
  layout_strategy = "center",
  borderchars = borderchars.center,
}

local layouts = {
  popup_list = vim.tbl_deep_extend("force", popup_list_base, {
    theme = "popup_list",
    layout_config = pct_layout(0.50),
  }),
  popup_extended = {
    theme = "popup_extended",
    prompt_title = false,
    results_title = false,
    preview_title = false,
    sorting_strategy = "descending",
    layout_strategy = "horizontal",
    layout_config = pct_layout(0.95),
    borderchars = borderchars.horizontal,
  },
}

telescope.setup({
  defaults = {
    border = true,
    prompt_title = false,
    results_title = false,
    color_devicons = true,
    layout_strategy = "horizontal",
    set_env = { ["COLORTERM"] = "truecolor" },
    sorting_strategy = "ascending",
    prompt_prefix = " search ",
    selection_caret = "  ",
    entry_prefix = "  ",
    initial_mode = "insert",
    path_display = { "truncate" },
    layout_config = {
      center = { prompt_position = "bottom" },
      horizontal = { prompt_position = "bottom" },
    },
    vimgrep_arguments = {
      "rg",
      "-L",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    },
    preview = { treesitter = true },
    mappings = {
      n = {
        q = telescope_actions.close,
        ["<C-v>"] = telescope_actions.select_vertical,
        ["<C-s>"] = telescope_actions.select_horizontal,
      },
      i = {
        ["<C-v>"] = telescope_actions.select_vertical,
        ["<C-s>"] = telescope_actions.select_horizontal,
      },
    },
  },
  extensions = {
    ["ui-select"] = telescope_themes.get_dropdown(popup_list_base),
  },
})


telescope.load_extension("ui-select")
local function use_layout(picker, layout)
  return function()
    picker(layouts[layout])
  end
end

keymap("n", "<leader>fg", use_layout(telescope_builtin.live_grep, "popup_extended"))
keymap("n", "<leader>ff", use_layout(telescope_builtin.find_files, "popup_list"))
keymap("n", "<leader>fb", use_layout(telescope_builtin.buffers, "popup_extended"))
keymap("n", "<leader>gg", use_layout(telescope_builtin.git_status, "popup_extended"))
