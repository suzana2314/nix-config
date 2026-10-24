-- Layer rules
for _, ns in ipairs(LAYER_NAMESPACES) do
  hl.layer_rule({
    match = { namespace = ns },
    blur = true,
    ignore_alpha = 0.5,
  })
end

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
