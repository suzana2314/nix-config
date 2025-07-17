{ config, ... }:
{
  programs.hyprlock = {
    enable = true;
    settings =
      let
        inherit (config.colorScheme) palette;
      in
      {
        general = {
          no_fade_in = false;
          no_fade_out = false;
          hide_cursor = true;
          grace = 1;
          disable_loading_bar = true;
          ignore_empty_input = true;
        };

        background = [
          {
            path = config.wallpaper;
            blur_passes = 4;
            noise = 0.0117;
            contrast = 1.3000;
            brightness = 0.8000;
            vibrancy = 0.2100;
            vibrancy_darkness = 0.0;
          }
        ];

        input-field = [
          {
            size = "250, 60";
            outline_thickness = 2;
            font_family = config.fontProfiles.regular.name;
            dots_size = 0.2;
            dots_spacing = 0.35;
            dots_center = true;
            fade_on_empty = true;
            rounding = 14;
            placeholder_text = ''<span foreground="##${palette.base06}">...</span>'';
            hide_input = false;
            position = "0, -50";
            halign = "center";
            valign = "center";
            outer_color = "rgba(29, 32, 33, 1)";
            inner_color = "rgba(29, 32, 33, 1)";
            font_color = "rgba(131, 165, 152, 1)";
            check_color = "rgb(250, 189, 47)";
            fail_color = "rgba(251, 73, 52, 1)";
          }
        ];

        label = [
          {
            text = ''cmd[update:1000] echo "<b><big> $(date +"%H:%M") </big></b>"'';
            text_align = "center";
            font_size = 42;
            font_family = config.fontProfiles.regular.name;
            color = "rgba(250, 189, 47, 1)";
            position = "0, 80";
            halign = "center";
            valign = "center";
          }
        ];
      };
  };
}
