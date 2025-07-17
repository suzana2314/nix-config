{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.cmp.enable = lib.mkEnableOption "enables cmp and lspkind modules";
  };

  config = lib.mkIf config.nixvim-config.plugins.cmp.enable {
    programs.nixvim = {
      plugins = {
        cmp = {
          enable = true;
          autoEnableSources = true;
          settings = {
            sources = [
              { name = "nvim_lua"; }
              { name = "nvim_lsp"; }
              { name = "nvim_lsp_signature_help"; }
              { name = "path"; } # filesystem
              { name = "buffer"; }
              { name = "luasnip"; }
              { name = "vimtex"; }
              { name = "latex_symbols"; }
            ];
            window = {
              documentation = {
                border = "rounded";
              };
            };
            mapping = {
              "<Tab>" = "cmp.mapping.select_next_item()";
              "<S-Tab>" = "cmp.mapping.select_prev_item()";
              "<C-j>" = "cmp.mapping.scroll_docs(4)";
              "<C-k>" = "cmp.mapping.scroll_docs(-4)";
              "<C-Space>" = "cmp.mapping.complete()";
              "<C-Esc>" = "cmp.mapping.close()";
              "<CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })";
            };
          };
        };

        lspkind.enable = true;
        lspkind.cmp.enable = true;
        cmp-nvim-lsp.enable = true;
        cmp-nvim-lua.enable = true;
        cmp-buffer.enable = true;
        cmp-path.enable = true;
        cmp-cmdline.enable = true;
        cmp_luasnip.enable = true;
        cmp-latex-symbols.enable = true;
        cmp-vimtex.enable = true;
        luasnip.enable = true;
      };
    };
  };
}
