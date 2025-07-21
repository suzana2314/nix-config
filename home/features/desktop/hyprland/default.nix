{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./screenshot.nix
    ./bitwarden-resize-script.nix
    ./monitor-listener.nix
  ];

  xdg.portal = {
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
    config.hyprland = {
      default = [
        "hyprland"
        "gtk"
      ];
    };
  };

  home.packages = with pkgs; [
    hyprpaper
    hyprlock
    hypridle
    hyprpolkitagent
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    settings =
      let
        inherit (config.colorScheme) palette;
      in
      {
        monitor = map (
          m:
          let
            resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
            position = "${toString m.x}x${toString m.y}";
          in
          "${m.name}, ${if m.enabled then "${resolution}, ${position},1" else "disable"}"
        ) config.monitors;

        workspace = lib.flatten (
          map (m: map (workspace: "${workspace},monitor:${m.name}") m.workspaces) (
            lib.filter (m: m.enabled && m.workspaces != [ ]) config.monitors
          )
        );

        input = {
          kb_layout = "us,pt";
          kb_options = "grp:caps_toggle";
          follow_mouse = 2;
          touchpad.natural_scroll = true;
          sensitivity = 0;
        };

        gestures = {
          workspace_swipe = true;
          workspace_swipe_forever = true;
          workspace_swipe_create_new = false;
          workspace_swipe_invert = false;
        };

        misc = {
          force_default_wallpaper = 0;
          animate_manual_resizes = true;
          animate_mouse_windowdragging = true;
          disable_hyprland_logo = true;
          new_window_takes_over_fullscreen = 2;
        };

        # ============================== STARTUP ==============================

        exec-once = [
          "waybar"
          "hyprpaper"
          "hypridle"
          "systemctl --user start hyprpolkitagent"
          "hyprctl setcursor ${config.gtk.cursorTheme.name} 1"
          "bitwarden-resize"
          "monitor-listener"
        ];

        # ============================== ENV ==============================
        # These are needed because of some electron apps

        env = [
          "XCURSOR_THEME,${config.gtk.cursorTheme.name}"
          "XCURSOR_PATH,~/.local/share/icons"
          "XCURSOR_SIZE,16"
          "HYPRCURSOR_THEME,${config.gtk.cursorTheme.name}"
          "HYPRCURSOR_SIZE,16"
          "QT_CURSOR_THEME,${config.gtk.cursorTheme.name}"
          "QT_CURSOR_SIZE,16"
          "XDG_SCREENSHOTS_DIR,~/pictures"
          "NIXOS_OZONE_WL,1"
        ];

        # ============================== BINDS ==============================

        binds = {
          workspace_center_on = 1;
        };

        binde = [
          # set brightness
          ",XF86MonBrightnessDown,exec, brightnessctl set 5%-"
          ",XF86MonBrightnessUp,exec, brightnessctl set +5%"
          "SUPER CTRL, h, resizeactive, -20 0"
          "SUPER CTRL, j, resizeactive, 0 20"
          "SUPER CTRL, k, resizeactive, 0 -20"
          "SUPER CTRL, l, resizeactive, 20 0"
        ];

        bind =
          let
            workspaces = [
              "1"
              "2"
              "3"
              "4"
              "5"
              "6"
              "7"
              "8"
              "9"
            ];
            directions = rec {
              left = "l";
              right = "r";
              up = "u";
              down = "d";
              h = left;
              l = right;
              k = up;
              j = down;
            };
          in
          [

            "SUPER, W, killactive,"

            # apps
            "SUPER, Return, exec, alacritty"
            "SUPER, Z, exec, firefox-beta"
            "SUPER, D, exec, wofi --show drun"
            "SUPER, E, exec, nautilus"
            "SUPER, P, exec, hyprlock"

            "SUPER, 0, workspace, 10"
            "SUPERSHIFT, 0, movetoworkspacesilent, name:10"

            "SUPER,f,fullscreen,1"
            "SUPERSHIFT,f,fullscreen,0"
            "SUPER,space,togglefloating"
            "SUPER,s,togglesplit"
            "SUPER,i,pseudo"
            "SUPERSHIFT,s,exec,screenshot-tool"
          ]
          ++
            # Change workspace
            (map (n: "SUPER,${n},workspace,${n}") workspaces)
          ++
            # Move window to workspace
            (map (n: "SUPERSHIFT,${n},movetoworkspacesilent,${n}") workspaces)
          ++
            # Move focus
            (lib.mapAttrsToList (key: direction: "SUPER,${key},movefocus,${direction}") directions)
          ++
            # Swap windows
            (lib.mapAttrsToList (key: direction: "SUPERSHIFT,${key},swapwindow,${direction}") directions);

        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
        ];

        # ============================== UI ==============================

        general = {
          layout = "dwindle";
          gaps_in = 5;
          gaps_out = 10;
          border_size = 0;
          allow_tearing = false;
          gaps_workspaces = 5;
          "col.active_border" = "0x${palette.base01}";
          "col.inactive_border" = "rgb(A4997F)";
        };

        dwindle = {
          preserve_split = "yes";
        };

        decoration = {
          rounding = 8;
          active_opacity = 1;
          inactive_opacity = 0.96;
          blur = {
            enabled = true;
            size = 5;
            passes = 3;
            new_optimizations = true;
            xray = false;
          };
        };

        animations = {
          enabled = true;
          bezier = [
            "linear, 0, 0, 1, 1"
            "md3_standard, 0.2, 0, 0, 1"
            "md3_decel, 0.05, 0.7, 0.1, 1"
            "md3_accel, 0.3, 0, 0.8, 0.15"
            "overshot, 0.05, 0.9, 0.1, 1.1"
            "crazyshot, 0.1, 1.5, 0.76, 0.92"
            "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
            "menu_decel, 0.1, 1, 0, 1"
            "menu_accel, 0.38, 0.04, 1, 0.07"
            "easeInOutCirc, 0.85, 0, 0.15, 1"
            "easeOutCirc, 0, 0.55, 0.45, 1"
            "easeOutExpo, 0.16, 1, 0.3, 1"
            "softAcDecel, 0.26, 0.26, 0.15, 1"
            "md2, 0.4, 0, 0.2, 1"
          ];
          animation = [
            "windows, 1, 3, md3_decel, popin 60%"
            "windowsIn, 1, 2, md3_decel, popin 60%"
            "windowsOut, 1, 2, md3_accel, popin 60%"
            "border, 1, 5, default"
            "fade, 1, 2, md3_decel"
            "workspaces, 1, 2, easeInOutCirc, slide"
            "specialWorkspace, 1, 2, md3_decel, slidevert"
          ];
        };

        windowrulev2 = [
          "opacity 1.0 override 1.0 override, class:(firefox)"
          "opacity 1.0 override 1.0 override, class:(PrusaSlicer)"
          "idleinhibit focus, title:.*YouTube.*"
          "idleinhibit fullscreen, title:.*"
        ];

      };
  };
}
