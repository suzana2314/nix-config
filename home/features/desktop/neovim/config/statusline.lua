local state = {
  show_path = false,
}

local config = {
  dim_hl = "CarbonIndicator",
  green = "GruvboxGreen",
  yellow = "DiagnosticWarn",
  red = "DiagnosticError",
  aqua = "DiagnosticHint",
  blue = "DiagnosticInfo"
}

vim.api.nvim_set_hl(0, "Statusline", { bg = '#282828', fg = '#ebdbb2' })
vim.api.nvim_set_hl(0, 'StatusLineNC', { link = "StatusLine" })
local function hl(group, text)
  return string.format("%%#%s#%s%%*", group, text)
end

local function filepath()
  if state.show_path then
    return " %f %{&modified?'*':''}"
  end
  return " " .. ".../" .. "%t %{&modified?'*':''}"
end
local function diagnostics()
  local counts = vim.diagnostic.count(0)
  local e = counts[vim.diagnostic.severity.ERROR] or 0
  local w = counts[vim.diagnostic.severity.WARN] or 0
  local h = counts[vim.diagnostic.severity.HINT] or 0

  if e == 0 and w == 0 and h == 0 then
    return ""
  end

  local parts = {}
  if e > 0 then table.insert(parts, hl(config.red, tostring(e))) end
  if w > 0 then table.insert(parts, hl(config.yellow, tostring(w))) end
  if h > 0 then table.insert(parts, hl(config.aqua, tostring(h))) end

  return hl(config.dim_hl, " | ") .. table.concat(parts, " ")
end

local function lsp()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return ""
  end
  return hl(config.dim_hl, " | ") .. hl(config.green, "ok ")
end

Statusline = {}
function Statusline.active()
  return table.concat {
    filepath(),
    diagnostics(),
    "%=at %c %%%p",
    lsp(),
  }
end

function Statusline.inactive()
  return " %t"
end

function Statusline.toggle_path()
  state.show_path = not state.show_path
  vim.cmd("redrawstatus")
end

vim.keymap.set("n", "<leader>sp", function() Statusline.toggle_path() end, { desc = "Toggle statusline path" })

local group = vim.api.nvim_create_augroup("Statusline", { clear = true })

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  group = group,
  desc = "Activate statusline on focus",
  callback = function()
    if vim.bo.buftype ~= "" then
      return
    end
    if vim.api.nvim_win_get_config(0).relative ~= "" then
      return
    end
    vim.opt_local.statusline = "%!v:lua.Statusline.active()"
    vim.cmd("redrawstatus")
  end,
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  group = group,
  desc = "Deactivate statusline when unfocused",
  callback = function()
    if vim.bo.buftype ~= "" then
      return
    end
    if vim.api.nvim_win_get_config(0).relative ~= "" then
      return
    end
    vim.opt_local.statusline = "%!v:lua.Statusline.inactive()"
  end,
})
