{ config, ... }:
{
  services.dunst =
    let
      inherit (config.colorScheme) palette;
    in
    {
      enable = true;
      settings = {
        global = {

          # general
          monitor = 0;
          follow = "mouse";
          idle_threshold = 60;
          format = "<b><u>%s</u></b>\n%b\n";

          # appearance
          width = 300;
          height = "(0, 300)";
          origin = "top-right";
          offset = "(20, 20)";
          font = config.fontProfiles.monospace.name;
          word_wrap = "yes";
          ignore_newline = "no";
          separator_height = 2;
          frame_width = 0;
          corner_radius = 10;
          separator_color = "#${palette.base01}";
          alignment = "left";

          # padding
          padding = 16;
          horizontal_padding = 16;
          text_icon_padding = 0;

          # icons
          icon_position = "left";
          min_icon_size = 0;
          max_icon_size = 50;

          # actions
          show_indicators = "yes";

          # binds
          mouse_left_click = "close_current";
          mouse_middle_click = "do_action,close_current";
          mouse_right_click = "close_all";

          # misc
          always_run_script = true;
          browser = "firefox";
        };

        urgency_low = {
          background = "#${palette.base01}e6";
          foreground = "#${palette.base0C}";
          timeout = 5;
        };

        urgency_normal = {
          background = "#${palette.base01}e6";
          foreground = "#${palette.base0C}";
          timeout = 5;
        };

        urgency_critical = {
          background = "#${palette.base08}e6";
          foreground = "#ffffff";
          timeout = 0;
        };
      };
    };
}
