local config = {
  dim_hl = "CarbonIndicator",
  selected_hl = "GruvboxGreenBold",
}

local function hl(group, text)
  return string.format("%%#%s#%s%%*", group, text)
end

vim.api.nvim_set_hl(0, "TabLineFill", { link = "StatusLine" })
vim.api.nvim_set_hl(0, "TabLine", { link = "StatusLine" })
vim.api.nvim_set_hl(0, "TabLineSel", { link = "StatusLine" })

Tabline = {}

function Tabline.render()
  local parts = {}
  local current = vim.api.nvim_get_current_tabpage()
  for i, tabid in ipairs(vim.api.nvim_list_tabpages()) do
    local winnr = vim.api.nvim_tabpage_get_win(tabid)
    local bufnr = vim.api.nvim_win_get_buf(winnr)
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
    if name == "" then name = "[No Name]" end

    local sep = i > 1 and hl(config.dim_hl, " | ") or " "
    local label = tabid == current
        and hl(config.selected_hl, name)
        or name

    parts[i] = sep .. label .. " "
  end
  return table.concat(parts)
end

vim.opt.showtabline = 1
vim.opt.tabline = "%!v:lua.Tabline.render()"
