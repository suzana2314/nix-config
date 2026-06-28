{ config, ... }:
let
  inherit (config.stylix) image fonts;
  inherit (config.lib.stylix) colors;
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        no_fade_in = false;
        no_fade_out = false;
        hide_cursor = true;
        grace = 1;
        disable_loading_bar = true;
        ignore_empty_input = false;
      };

      background = [
        {
          path = image;
          blur_passes = 4;
          noise = 0.0117;
          contrast = 1.3000;
          brightness = 0.8000;
          vibrancy = 0.2100;
          vibrancy_darkness = 0.0;
        }
      ];

      input-field = with colors; [
        {
          size = "250, 60";
          outline_thickness = 2;
          font_family = fonts.monospace.name;
          dots_size = 0.2;
          dots_spacing = 0.35;
          dots_center = true;
          fade_on_empty = true;
          rounding = 14;
          placeholder_text = ''<span foreground="#${withHashtag.base06}">...</span>'';
          hide_input = false;
          position = "0, -50";
          halign = "center";
          valign = "center";
          outer_color = "rgb(${base03})";
          inner_color = "rgb(${base00})";
          font_color = "rgb(${base05})";
          check_color = "rgb(${base0A})";
          fail_color = "rgb(${base08})";
        }
      ];

      label = with colors; [
        {
          text = ''cmd[update:1000] echo "<b><big> $(date +"%H:%M") </big></b>"'';
          text_align = "center";
          font_size = 42;
          font_family = fonts.monospace.name;
          color = "rgb(${base0A})";
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
