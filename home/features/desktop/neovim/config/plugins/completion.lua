require('blink.cmp').setup({
  keymap = { preset = 'enter' },
  appearance = {
    nerd_font_variant = 'mono'
  },

  completion = {

    menu = {
      border = "rounded",
      winhighlight = 'Normal:NormalFloat,FloatBorder:NormalFloat,CursorLine:BlinkCmpMenuSelection,Search:None',
    },

    documentation = {
      auto_show = true
    },
  },

  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },


  fuzzy = { implementation = "prefer_rust_with_warning" }
})
