-- Layer rules
for _, ns in ipairs(LAYER_NAMESPACES) do
  hl.layer_rule({
    match = { namespace = ns },
    blur = true,
    ignore_alpha = 0.5,
  })
end

hl.layer_rule({
  name = "noctalia",
  match = {
    namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
  },
  no_anim = true,
  ignore_alpha = 0.5,
  blur = true,
  blur_popups = true,
})

-- Window rules
for _, c in ipairs(PSEUDO_CLASSES) do
  hl.window_rule({
    match = { class = c },
    size = { "monitor_w * 0.75", "monitor_h * 0.75" },
  })
end

hl.window_rule({ match = { class = "firefox" }, opacity = "1.0 override 1.0 override 1.0 override" })
-- here order matters!
hl.window_rule({ match = { title = ".*" }, idle_inhibit = "fullscreen" })
hl.window_rule({ match = { title = ".*YouTube.*" }, idle_inhibit = "focus" })
hl.window_rule({
  match = { class = "dev.noctalia.Noctalia" },
  float = true,
  size = { 1080, 920 },
})

hl.window_rule({
  -- Fix some dragging issues with XWayland
  name     = "fix-xwayland-drags",
  match    = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },
  no_focus = true,
})
