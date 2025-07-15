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
          format = "<small><b>%a :</b>%s</small>\n%b";

          # appearance
          width = 300;
          height = 300;
          origin = "top-right";
          offset = "20x20";
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

          # Icons
          icon_position = "left";
          min_icon_size = 0;
          max_icon_size = 50;

          # misc
          always_run_script = true;

        };

        urgency_low = {
          background = "#282828";
          foreground = "#${palette.base0C}";
          timeout = 5;
        };

        urgency_normal = {
          background = "#282828";
          foreground = "#${palette.base0C}";
          timeout = 5;
        };

        urgency_critical = {
          background = "#${palette.base08}";
          foreground = "#ffffff";
          timeout = 0;
        };
      };
    };
}
