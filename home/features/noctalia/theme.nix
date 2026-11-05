{ config, ... }:
let
  inherit (config.lib.stylix) colors;
  hex = c: "#${c}";

  palette = {
    version = 2;
    dark = with colors; {
      primary = hex base0A;
      on_primary = hex base00;
      secondary = hex base0C;
      on_secondary = hex base00;
      tertiary = hex base0E;
      on_tertiary = hex base00;
      error = hex base08;
      on_error = hex base00;

      surface = hex base00;
      on_surface = hex base05;
      surface_container = hex base01;
      on_surface_variant = hex base04;
      outline_variant = hex base02;
      shadow = hex base00;
      hover = hex base02;
      on_hover = hex base06;

      terminal = {
        background = hex base00;
        foreground = hex base05;
        cursor = hex base05;
        cursor_text = hex base00;
        selection_bg = hex base02;
        selection_fg = hex base05;
        normal = {
          black = hex base00;
          red = hex base08;
          green = hex base0B;
          yellow = hex base0A;
          blue = hex base0D;
          magenta = hex base0E;
          cyan = hex base0C;
          white = hex base05;
        };
        bright = {
          black = hex base03;
          red = hex base08;
          green = hex base0B;
          yellow = hex base0A;
          blue = hex base0D;
          magenta = hex base0E;
          cyan = hex base0C;
          white = hex base07;
        };
      };
    };
  };
in
{
  xdg.configFile."noctalia/palettes/stylix.json".text = builtins.toJSON palette;
}
