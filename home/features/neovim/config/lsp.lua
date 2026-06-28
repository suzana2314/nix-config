vim.lsp.enable({
  "nixd",
  "nil_ls",
  "lua_ls",
  "bashls",
  "ty",
  "ruff",
  "gopls",
  "rust_analyzer",
  "yamlls",
  "zls"
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
