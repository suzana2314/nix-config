local modes = {
  ["n"] = "normal",
  ["no"] = "normal",
  ["v"] = "visual",
  ["V"] = "visual line",
  ["^V"] = "visual block",
  ["s"] = "select",
  ["S"] = "select line",
  ["^S"] = "select block",
  ["i"] = "insert",
  ["ic"] = "insert",
  ["R"] = "replace",
  ["Rv"] = "visual replace",
  ["c"] = "command",
  ["cv"] = "vim ex",
  ["ce"] = "ex",
  ["r"] = "prompt",
  ["rm"] = "moar",
  ["r?"] = "confirm",
  ["!"] = "shell",
  ["t"] = "terminal",
}

local mode_colors = {
  n = "%#GruvboxBlueBold#",
  i = "%#GruvboxGreenBold#",
  ic = "%#GruvboxGreenBold#",
  v = "%#GruvboxOrangeBold#",
  V = "%#GruvboxOrangeBold#",
  ["^V"] = "%#GruvboxOrangeBold#",
  R = "%#GruvboxRedBold#",
  c = "%#GruvboxPurpleBold#",
  t = "%#GruvboxAquaBold#",
}

-- lovme some hardcoded hexes
vim.api.nvim_set_hl(0, 'StatusLine', { bg = '#282828', fg = '#ebdbb2' })
vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = '#282828', fg = '#ebdbb2' })
vim.api.nvim_set_hl(0, 'StatusLineLSP', { bg = '#282828', fg = '#b8bb26' })

local function get_statusline()
  local current_mode = vim.api.nvim_get_mode().mode
  local mode_color = mode_colors[current_mode] or ""
  local mode_text = string.format(" %s ", (modes[current_mode] or "unknown"):upper())

  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local lsp_status = #clients > 0 and "%#StatusLineLSP#attchd%#StatusLine# " or ""

  return mode_color .. mode_text .. "%#StatusLine# %f %{&modified?'*':''}%=at %c | %%%p | " .. lsp_status
end

local function update_statusline()
  vim.o.statusline = get_statusline()
  vim.cmd("redrawstatus")
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "ShellCmdPost", "ModeChanged", "LspAttach", "LspDetach" }, {
  pattern = "*",
  callback = function()
    local filename = vim.fn.bufname("%")
    local buftype = vim.bo.buftype

    if filename == "" or buftype ~= "" then
      vim.opt_local.statusline = " "
    else
      update_statusline()
    end
  end,
})

vim.o.statusline = get_statusline()
