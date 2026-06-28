-- do not set undofile for files in /tmp
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '/tmp/*',
  group = vim.api.nvim_create_augroup('tempdir', { clear = true }),
  callback = function()
    vim.cmd.setlocal('noundofile')
  end,
})

--- don't create a comment string when hitting <enter> on a comment line
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('DisableNewLineAutoCommentString', {}),
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions - { 'c', 'r', 'o' }
  end
})

-- treesitter
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

-- lsp
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local map = vim.keymap.set
    local buf = vim.lsp.buf

    if not client then return end
    if client.server_capabilities.codeActionProvider then
      vim.lsp.codelens.enable(true, { bufnr = bufnr })
    end

    local function opts()
      return { noremap = true, silent = true, buffer = bufnr }
    end

    if client and client.server_capabilities.inlayHintProvider then
      map('n', '<space>h', function()
        local current_setting = vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }
        vim.lsp.inlay_hint.enable(not current_setting, { bufnr = bufnr })
      end, opts())
    end

    map('n', 'gD', buf.declaration, opts())
    map('n', 'gd', buf.definition, opts())
    map('n', 'K', buf.hover, opts())
    map('n', 'gi', buf.implementation, opts())
    map({ 'n', 'v' }, '<leader>rn', buf.rename, opts())
    map('n', '<leader>ca', buf.code_action, opts())
    map('n', 'gr', buf.references, opts())
    map('n', '<space>f', function() buf.format { async = true } end, opts())
  end
})
