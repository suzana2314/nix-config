{ inputs, ... }:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./keymappings.nix
    ./plugins
    ./colorschemes.nix
  ];

  programs.nixvim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;

    clipboard.providers.wl-copy.enable = true;

    performance = {
      combinePlugins.enable = true;
      byteCompileLua.enable = true;
    };

    diagnostic.settings = {
      virtual_text = false;
      underline = true;
      signs = true;
      severity_sort = true;
    };

    opts = {

      # ===== general ======
      showmode = false; # remove the mode (already is in lualine)
      visualbell = true; # no sounds
      ruler = true; # show current line and column
      cmdheight = 1;
      hid = true; # a buffer becomes hidden when abandoned
      autoread = true; # reload files changed outside vim
      lazyredraw = true; # redraw only when needed
      showmatch = true; # highlight matching braces

      listchars = "trail:·"; # display tabs and trailing spaces visually
      number = true; # display line numbers
      signcolumn = "number"; # makes so the signs appear in the number column!

      wrap = false;
      linebreak = true; # wrap lines at convenient places

      # ===== identation ======
      autoindent = true;
      cindent = true; # automatically indent braces
      smartindent = true;
      # 1 tab == 2 spaces
      tabstop = 2;
      shiftwidth = 2;
      # this uses spaces instead of tabs
      expandtab = true;
      smarttab = true;

      # ===== scrolling =====
      scrolloff = 4; # start scrolling when we're 4 lines away from margins
      sidescrolloff = 15;
      sidescroll = 1;

      # ==== searching ====
      incsearch = true; # searches incrementally as you type instead of after 'enter'
      hlsearch = true; # highlight search results
      ignorecase = true; # search case insensitive
      smartcase = true; # search matters if capital letter
      inccommand = "split"; # preview incremental substitutions in a split

      # ==== splits =====
      splitbelow = true;
      splitright = true;
    };

    extraConfigLua = ''
      vim.opt.mouse=""
      vim.cmd('highlight clear DiagnosticSignError')
      vim.cmd('highlight clear DiagnosticSignWarn')
      vim.cmd('highlight clear DiagnosticSignInfo')
      vim.cmd('highlight clear DiagnosticSignHint')
      vim.cmd('highlight clear NormalFloat')

      vim.o.winborder = 'rounded'
      -- fix for telescope
      vim.api.nvim_create_autocmd("User", {
        pattern = "TelescopeFindPre",
        callback = function()
          vim.opt_local.winborder = "none"
          vim.api.nvim_create_autocmd("WinLeave", {
            once = true,
            callback = function()
              vim.opt_local.winborder = "rounded"
            end,
          })
        end,
      })

      local lspconfig = require("lspconfig")

      local on_attach = function(_, bufnr)
          local codelens_group = vim.api.nvim_create_augroup("LSPCodeLens", { clear = true })
          vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "CursorHold" }, {
              group = codelens_group,
              buffer = bufnr,
              callback = function()
                  vim.lsp.codelens.refresh()
              end,
          })
      end
      lspconfig.ocamllsp.setup {
        settings = {
          codelens = { enable = true },
        },
        on_attach = on_attach,
      }
    '';
  };
}
