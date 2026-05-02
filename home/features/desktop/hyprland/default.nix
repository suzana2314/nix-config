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
    ./scripts
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

  # fixes screen sharing asking multiple times
  xdg.configFile."hypr/xdph.conf".text = ''
    screencopy {
      allow_token_by_default = true
    }
  '';

  home.packages = with pkgs; [
    hyprpaper
    hyprlock
    hypridle
    hyprpolkitagent
    playerctl
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;

    settings = {
      monitorv2 = map (
        m:
        let
          resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}.0";
          position = "${toString m.x}x${toString m.y}";
        in
        if m.enabled then
          {
            output = "desc:${m.description}";
            mode = resolution;
            position = position;
            scale = m.scale;
            bitdepth = m.bitdepth;
          }
        else
          {
            output = "desc:${m.description}";
            disabled = true;
          }
      ) config.monitors;

      render = {
        cm_fs_passthrough = 1;
        cm_auto_hdr = 1;
        cm_enabled = true;
      };

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

      misc = {
        force_default_wallpaper = 0;
        animate_manual_resizes = true;
        animate_mouse_windowdragging = true;
        disable_hyprland_logo = true;
        focus_on_activate = true;
        initial_workspace_tracking = 2;
      };

      # ============================== STARTUP ==============================

      exec-once = [
        "waybar"
        "hyprpaper"
        "hypridle"
        "systemctl --user start hyprpolkitagent"
        "hyprctl setcursor ${config.gtk.cursorTheme.name} 1"
        "monitor-listener"
      ];

      # ============================== ENV ==============================
      # These are needed because of some electron apps

      env = [
        "XCURSOR_THEME,${config.gtk.cursorTheme.name}"
        "XCURSOR_PATH,${config.xdg.dataHome}/icons"
        "XCURSOR_SIZE,16"
        "HYPRCURSOR_THEME,${config.gtk.cursorTheme.name}"
        "HYPRCURSOR_SIZE,16"
        "QT_CURSOR_THEME,${config.gtk.cursorTheme.name}"
        "QT_CURSOR_SIZE,16"
        "XDG_SCREENSHOTS_DIR,~/pictures"
        "NIXOS_OZONE_WL,1"
        "AQ_DRM_DEVICES,/dev/dri/card1:/dev/dri/card0"
      ];

      # ============================== BINDS ==============================

      binds = {
        workspace_center_on = 1;
      };

      binde = [
        # set brightness
        ",XF86MonBrightnessDown,exec, brightnessctl set 5%-"
        ",XF86MonBrightnessUp,exec, brightnessctl set +5%"
        # set audio
        ",XF86AudioRaiseVolume,exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
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
          # apps
          "SUPER, Return, exec, ghostty +new-window"
          "SUPER, Z, exec, firefox"
          "SUPER, D, exec, wofi --show drun"
          "SUPER, E, exec, nautilus"

          # utils
          "SUPER, W, killactive,"
          "SUPER, T, exec, monitor-switcher"
          "SUPER, P, exec, hyprlock"

          # windows
          "SUPER,f,fullscreen,1"
          "SUPERSHIFT,f,fullscreen,0"
          "SUPER,space,togglefloating"
          "SUPER,s,togglesplit"
          "SUPER,i,pseudo"
          "SUPERSHIFT,s,exec,screenshot-tool"

          "SUPER, 0, workspace, 10"
          "SUPERSHIFT, 0, movetoworkspacesilent, name:10"

          # audio
          ",XF86AudioMute,exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ",XF86AudioNext, exec, playerctl next"
          ",XF86AudioPrev, exec, playerctl previous"
          ",XF86AudioPlay, exec, playerctl pause"
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
      };

      dwindle = {
        preserve_split = "yes";
      };

      layerrule = [
        "blur on, match:namespace notifications"
        "ignore_alpha 0.5, match:namespace notifications"
        "blur on, match:namespace waybar"
        "ignore_alpha 0.8, match:namespace waybar"
      ];

      decoration = {
        rounding = 8;
        active_opacity = 1;
        inactive_opacity = 0.95;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          new_optimizations = true;
          xray = false;
        };
        shadow = {
          enabled = true;
          range = 6;
          render_power = 4;
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

      windowrule = [
        "opacity 1.0 override 1.0 override 1.0 override, match:class firefox"
        "idle_inhibit focus, match:title .*YouTube.*"
        "idle_inhibit fullscreen, match:title .*"
      ];
    };
  };
}
