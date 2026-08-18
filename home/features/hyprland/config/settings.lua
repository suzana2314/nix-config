-- Startup
hl.on("hyprland.start", function()
  hl.exec_cmd("waybar")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("hyprctl setcursor " .. CURSOR_THEME .. " 1")
  hl.exec_cmd("monitor-listener")
end)

-- Env
hl.env("XCURSOR_THEME", CURSOR_THEME)
hl.env("XCURSOR_PATH", DATA_HOME .. "/icons")
hl.env("XCURSOR_SIZE", "16")
hl.env("HYPRCURSOR_THEME", CURSOR_THEME)
hl.env("HYPRCURSOR_SIZE", "16")
hl.env("QT_CURSOR_THEME", CURSOR_THEME)
hl.env("QT_CURSOR_SIZE", "16")
hl.env("XDG_SCREENSHOTS_DIR", PICTURE_HOME)
hl.env("NIXOS_OZONE_WL", "1")

-- Settings
hl.config({
  input = {
    kb_layout = "us,pt",
    kb_options = "grp:caps_toggle",
    follow_mouse = 2,
    touchpad = { natural_scroll = true },
    sensitivity = 0,
  },

  misc = {
    force_default_wallpaper = 0,
    animate_manual_resizes = true,
    animate_mouse_windowdragging = true,
    disable_hyprland_logo = true,
    focus_on_activate = true,
    initial_workspace_tracking = 2,
  },

  binds = { workspace_center_on = 1 },

  general = {
    layout = "dwindle",
    gaps_in = 5,
    gaps_out = 10,
    border_size = 0,
    allow_tearing = false,
    gaps_workspaces = 5,
  },

  dwindle = { preserve_split = true },

  decoration = {
    rounding = 8,
    active_opacity = 1,
    inactive_opacity = 0.95,
    blur = {
      enabled = true,
      size = 5,
      passes = 3,
      new_optimizations = true,
      xray = false,
    },
    shadow = {
      enabled = true,
      range = 6,
      render_power = 4,
    },
  },

  animations = { enabled = true },
})
