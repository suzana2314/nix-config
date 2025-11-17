
local function extra_mode_status()
  -- recording macros
  local reg_recording = vim.fn.reg_recording()
  if reg_recording ~= '' then
    return ' @' .. reg_recording
  end
  -- executing macros
  local reg_executing = vim.fn.reg_executing()
  if reg_executing ~= '' then
    return ' @' .. reg_executing
  end
  return ''
end

require('lualine').setup {
  globalstatus = true,
  sections = {
    lualine_a = {
      { 'mode', icon = "" },
    },
    lualine_b = {
      { 'branch', icon = "" },
      { 'diff', symbols = {
        added = " ",
        modified = " ",
        removed = " ",
      } }
    },
    lualine_c = {
      { 'diagnostics',
        sources = { "nvim_lsp" },
        symbols = {
          error = " ",
          warn = " ",
          info = " ",
          hint = "󰝶 ",
        }
      }
    },
    lualine_x = {
      { 'filetype',
        icon_only = true,
        separator = "",
        padding = {
          left = 1,
          right = 1,
        }
      },
      { 'filename',
        path = 1,
      }
    },
    lualine_y = {
      { 'progress' }
    },
    lualine_z = {
      { extra_mode_status },
      {
        'lsp_status',
        icon = '', -- f013
        symbols = {
          -- Standard unicode symbols to cycle through for LSP progress:
          spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
          -- Standard unicode symbol for when LSP is done:
          done = '✓',
          -- Delimiter inserted between LSP names:
          separator = ' ',
        },
        -- List of LSP names to ignore (e.g., `null-ls`):
        ignore_lsp = {},
      }
    },
  },
  options = {
    theme = 'auto',
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
  },
}

