vim.lsp.enable({ "lua_ls", "nixd", "jdtls", "gopls" })

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT"
      };
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true)
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
