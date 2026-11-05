{
  programs.noctalia.settings = {
    bar.default = {
      color = "secondary";
      icon_color = "primary";
      start = [ "clock" ];
      center = [ "workspaces" ];
      end = [
        "tray"
        "keyboard_layout"
        "notifications"
        "volume"
        "network"
        "bluetooth"
        "battery"
      ];
      font_weight = 400;
      margin_edge = 10;
      margin_ends = 10;
      padding = 15;
      thickness = 40;
      widget_spacing = 10;
      radius = 10;
      capsule_radius = 10;
      background_opacity = 0.98;
      concave_edge_corners = false;
      show_tooltip = false;
    };

    widget = {
      battery.peek = true;
      bluetooth = {
        hide_when_no_connected_device = true;
        icon_color = "on_tertiary_container";
      };
      clock = {
        format = "{:%a, %d de %B | %H:%M}";
      };
      keyboard_layout = {
        show_glyph = false;
        font_scale = 0.90;
      };
      network = {
        color = "primary";
        glyph_position = "after";
        icon_color = "primary";
        show_label = false;
      };
      notifications = {
        color = "on_tertiary_container";
        hide_when_no_unread = true;
        icon_color = "on_tertiary_container";
      };
      tray = {
        detached_panel = true;
        drawer = true;
        icon_type = "desktop";
      };
      volume = {
        icon_color = "tertiary";
        show_label = false;
      };
      workspaces = {
        active_pill_size = 2.0;
        focused_output_only = true;
        pill_scale = 0.75;
        separator = " ";
        show_labels = false;
      };
    };
  };
}
