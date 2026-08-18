-- App binds
hl.bind(MOD .. " + Return", hl.dsp.exec_cmd(TERM .. " +new-window"))
hl.bind(MOD .. " + Z", hl.dsp.exec_cmd("firefox"))
hl.bind(MOD .. " + D", hl.dsp.exec_cmd("wofi --show drun"))
hl.bind(MOD .. " + E", hl.dsp.exec_cmd("nautilus"))
hl.bind(MOD .. " + T", hl.dsp.exec_cmd("monitor-switcher"))
hl.bind(MOD .. " + P", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(MOD .. " + SHIFT + S", hl.dsp.exec_cmd("screenshot-tool"))

-- Special keys
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl pause"), { locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { locked = true, repeating = true })

-- Mouse
hl.bind(MOD .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(MOD .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Workspaces
for i = 1, 10 do
  local key = i % 10
  hl.bind(MOD .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(MOD .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Movement
hl.bind(MOD .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(MOD .. " + J", hl.dsp.focus({ direction = "d" }))
hl.bind(MOD .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(MOD .. " + L", hl.dsp.focus({ direction = "r" }))

hl.bind(MOD .. " + SHIFT + H", hl.dsp.window.swap({ direction = "l" }))
hl.bind(MOD .. " + SHIFT + J", hl.dsp.window.swap({ direction = "d" }))
hl.bind(MOD .. " + SHIFT + K", hl.dsp.window.swap({ direction = "u" }))
hl.bind(MOD .. " + SHIFT + L", hl.dsp.window.swap({ direction = "r" }))

hl.bind(MOD .. " + CTRL + H", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind(MOD .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
hl.bind(MOD .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind(MOD .. " + CTRL + L", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })

hl.bind(MOD .. " + W", hl.dsp.window.close())
hl.bind(MOD .. " + I", hl.dsp.window.pseudo())
hl.bind(MOD .. " + S", hl.dsp.layout("togglesplit"))
hl.bind(MOD .. " + F", hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(MOD .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = 0 }))
hl.bind(MOD .. " + SPACE", hl.dsp.window.float({ action = "toggle" }))
