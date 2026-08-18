-- Curves
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("md3_standard", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } })
hl.curve("md3_decel", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("md3_accel", { type = "bezier", points = { { 0.3, 0 }, { 0.8, 0.15 } } })
hl.curve("easeInOutCirc", { type = "bezier", points = { { 0.85, 0 }, { 0.15, 1 } } })
hl.curve("easeOutCirc", { type = "bezier", points = { { 0, 0.55 }, { 0.45, 1 } } })
hl.curve("easeOutExpo", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })

-- Animations
hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "md3_decel", style = "popin 60%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2, bezier = "md3_decel", style = "popin 60%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "md3_accel", style = "popin 60%" })
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 2, bezier = "md3_decel" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "easeInOutCirc", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2, bezier = "md3_decel", style = "slidevert" })
