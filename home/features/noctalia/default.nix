{ inputs, config, ... }:
let
  inherit (config.stylix.fonts) monospace;
in
{
  imports = [
    inputs.noctalia.homeModules.default
    ./bar.nix
    ./theme.nix
  ];

  programs.noctalia = {
    enable = true;
    settings = {
      audio = {
        enable_notification_sounds = false;
        enable_sounds = false;
        enable_volume_sounds = false;
      };

      calendar = {
        enabled = true;
        refresh_minutes = 5;
        account.local_calendar = {
          path = "${config.xdg.dataHome}/calendar/sync";
          type = "vdir";
        };
      };

      control_center = {
        hidden_tabs = [
          "monitor"
          "weather"
          "calendar"
          "screen-time"
        ];
        show_avatar_border = false;
        show_session_button = false;
        show_shortcut_labels = false;
        shortcuts = [
          { type = "wifi"; }
          { type = "bluetooth"; }
          { type = "caffeine"; }
          { type = "notification"; }
          { type = "power_profile"; }
          { type = "mic_mute"; }
        ];
      };

      desktop_widgets.enabled = false;
      lockscreen.enabled = false;
      lockscreen_widgets.enabled = false;
      wallpaper.enabled = false;
      weather.enabled = false;

      keybinds = {
        down = [ "Tab" ];
        up = [ "Shift+ISO_Left_Tab" ];
        tab_next = [ "Down" ];
        tab_previous = [ "Up" ];
      };

      notification = {
        background_opacity = 0.90;
        border = false;
        follow_focused_output = true;
        newest_on_edge = true;
        offset_x = 10;
        offset_y = 10;
        show_app_name = false;
      };

      osd = {
        border = false;
        follow_focused_output = true;
      };

      shell = {
        # TODO: put this in another place
        avatar_path = "/home/suz/pictures/profile_pictures/main/pfp_7.png";
        font_family = monospace.name;
        launch_apps_as_systemd_services = false;
        launch_apps_custom_command = "uwsm app -- $CMD";

        clipboard_enabled = false;
        clipboard_keep_from_closed_apps = false;
        settings_expand_all_groups = true;
        settings_show_advanced = false;
        settings_window_translucent = false;
        show_close_buttons = false;
        button_borders = false;
        card_borders = false;
        input_borders = false;
        popup_borders = false;
        circular_avatar = false;

        launcher = {
          categories = false;
          compact = true;
          fetch_exchange_rates = false;
          ignore_mouse = false;
          layout = "simple";
        };
        panel = {
          borders = false;
          clipboard_position = "top_right";
          control_center_placement = "floating";
          floating_layer = "top";
          open_near_click_control_center = true;
          session_placement = "floating";
          wallpaper_placement = "floating";
          wallpaper_position = "center";
          wallpaper_show_names = false;
        };
        session.show_shortcuts = false;
        shadow = {
          alpha = 0.80;
          direction = "down_right";
        };
        screenshot = {
          region_border_width = 1.0;
          save_to_file = false;
        };
      };

      theme = {
        mode = "dark";
        source = "custom";
        custom_palette = "stylix";
      };
    };

    systemd = {
      enable = true;
    };
  };

}
