local tempdirgroup = vim.api.nvim_create_augroup('tempdir', { clear = true })
-- Do not set undofile for files in /tmp
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '/tmp/*',
  group = tempdirgroup,
  callback = function()
    vim.cmd.setlocal('noundofile')
  end,
})

-- LSP
local map = vim.keymap.set

--- Don't create a comment string when hitting <Enter> on a comment line
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('DisableNewLineAutoCommentString', {}),
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions - { 'c', 'r', 'o' }
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    vim.bo[bufnr].bufhidden = 'hide'

    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
    local function opts()
      return { noremap = true, silent = true, buffer = bufnr}
    end
    map('n', 'gD', vim.lsp.buf.declaration, opts())
    map('n', 'gd', vim.lsp.buf.definition, opts())
    map('n', 'K', function() vim.lsp.buf.hover { border = 'rounded', } end, opts())
    map('n', 'gi', vim.lsp.buf.implementation, opts())
    map('n', '<leader>rn', vim.lsp.buf.rename, opts())
    map('n', '<leader>ca', vim.lsp.buf.code_action, opts())
    map('n', 'gr', vim.lsp.buf.references, opts())
    map('n', '<space>f', function() vim.lsp.buf.format { async = true } end, opts())

    if client and client.server_capabilities.inlayHintProvider then
      map('n', '<space>h', function()
        local current_setting = vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }
        vim.lsp.inlay_hint.enable(not current_setting, { bufnr = bufnr })
      end, opts())
    end

    -- auto-refresh code lenses
    if not client then
      return
    end
    if client.server_capabilities.codeLensProvider then
      vim.lsp.codelens.enable(true, {bufnr = bufnr})
    end
  end,
})

-- Treesitter

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "*" },
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local lang = vim.treesitter.language.get_lang(ft)
    if lang and vim.treesitter.language.add(lang) then
      vim.treesitter.start(args.buf, lang)
    end
  end,
})

