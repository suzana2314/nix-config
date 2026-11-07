-- Startup
local app = "uwsm app -- "
hl.on("hyprland.start", function()
  hl.exec_cmd(app .. "hyprpaper")
  hl.exec_cmd(app .. "hypridle")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("hyprctl setcursor " .. CURSOR_THEME .. " 1")
end)

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
    inactive_opacity = OPACITY,
    blur = {
      enabled = true,
      size = 5,
      passes = 3,
      new_optimizations = true,
      xray = false,
    },
    shadow = {
      enabled        = true,
      range          = 60,
      render_power   = 2,
      sharp          = false,
      color          = "rgba(00000066)",
      color_inactive = "rgba(00000033)",
      offset         = { 0, 24 },
      scale          = 1.0,
    },
    motion_blur = { enabled = true, },
  },

  animations = { enabled = true },
})
