local map = vim.keymap.set
local api = vim.api
-- copy to clipboard
map({ 'n', 'v'}, '<leader>y', '\"+y')

-- disable highlights
map('n', '<space><space>', '<cmd>noh<CR>')

--open diagnostics
map('n', '<leader>cd', function()
  local _, winid = vim.diagnostic.open_float(nil, { scope = 'line' })
  if not winid then
    vim.notify('no diagnostics found', vim.log.levels.INFO)
    return
  end
  vim.api.nvim_win_set_config(winid or 0, { focusable = true })
end, { noremap = true, silent = true, desc = 'diagnostics floating window' })


-- resize splits
local toIntegral = math.ceil
map('n', '<leader>w+', function()
  local curWinWidth = api.nvim_win_get_width(0)
  api.nvim_win_set_width(0, toIntegral(curWinWidth * 3 / 2))
end, { silent = true, desc = 'inc window [w]idth' })
map('n', '<leader>w-', function()
  local curWinWidth = api.nvim_win_get_width(0)
  api.nvim_win_set_width(0, toIntegral(curWinWidth * 2 / 3))
end, { silent = true, desc = 'dec window [w]idth' })
map('n', '<leader>h+', function()
  local curWinHeight = api.nvim_win_get_height(0)
  api.nvim_win_set_height(0, toIntegral(curWinHeight * 3 / 2))
end, { silent = true, desc = 'inc window [h]eight' })
map('n', '<leader>h-', function()
  local curWinHeight = api.nvim_win_get_height(0)
  api.nvim_win_set_height(0, toIntegral(curWinHeight * 2 / 3))
end, { silent = true, desc = 'dec window [h]eight' })


-- telescope
map('n', '<leader>ff', "<cmd>Telescope find_files<CR>")
map('n', '<leader>fg', "<cmd>Telescope live_grep<CR>")
map('n', '<leader>fb', "<cmd>Telescope buffers<CR>")

-- oil
map('n', '<leader>e', '<cmd>Oil --float<CR>')
