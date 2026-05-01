vim.lsp.enable({
  "nixd",
  "lua_ls",
  "bashls",
  "ty",
  "ruff",
  "gopls",
  "rust_analyzer",
  "yamlls",
  "zls"
})

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT"
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        maxPreload = 100000,
        preLoadFileSize = 1000,
      }
    }
  },
})

vim.lsp.config('nixd', {
  settings = {
    nixd = {
      formatting = {
        command = { "nixfmt" }
      },
      options = {
        nixos = '(builtins.getFlake (builtins.toString /home/suz/.nix/nix-config)).nixosConfigurations.master.options',                                  -- can't think of a better way to get the path maybe with an env?
        home_manager =
        '(builtins.getFlake (builtins.toString /home/suz/.nix/nix-config)).nixosConfigurations.master.options.home-manager.users.type.getSubOptions []', -- using the home manager module
      },
    },
  },
})

vim.lsp.config('yamlls', {
  settings = {
    yaml = {
      customTags = {
        "!secret scalar",
        "!lambda scalar",
        "!include scalar",
        "!include_dir_list scalar",
        "!include_dir_named scalar",
        "!include_dir_merge_list scalar",
        "!include_dir_merge_named scalar",
        "!extend scalar",
        "!remove scalar"
      }
    }
  },
})
