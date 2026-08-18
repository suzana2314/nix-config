-- Layer rules
hl.layer_rule({
  match = { namespace = "notifications" },
  blur = true,
  ignore_alpha = 0.5,
})
hl.layer_rule({
  match = { namespace = "waybar" },
  blur = true,
  ignore_alpha = 0.8,
})

-- Window rules
hl.window_rule({ match = { class = "firefox" }, opacity = "1.0 override 1.0 override 1.0 override" })
hl.window_rule({ match = { title = ".*YouTube.*" }, idle_inhibit = "focus" })
hl.window_rule({ match = { title = ".*" }, idle_inhibit = "fullscreen" })
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
