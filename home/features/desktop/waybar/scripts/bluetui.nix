{ pkgs, ... }:
let
  bluetui-widget = pkgs.writeShellApplication {
    name = "bluetui-widget";
    runtimeInputs = [
      pkgs.jq
      pkgs.hyprland
    ];
    text = ''
      WINDOW_WIDTH=500
      WINDOW_HEIGHT=800
      WAYBAR_HEIGHT=40
      PADDING=10

      monitor_info=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true)')
      monitor_name=$(echo "$monitor_info" | jq -r '.name')
      monitor_width=$(echo "$monitor_info" | jq -r '.width')

      x_pos=$((monitor_width - WINDOW_WIDTH - PADDING))
      y_pos=$((WAYBAR_HEIGHT + 2 * PADDING))

      hyprctl dispatch exec "[float;monitor $monitor_name;size $WINDOW_WIDTH $WINDOW_HEIGHT;move $x_pos $y_pos] alacritty --class bluetui -e bluetui"
    '';
  };
in
{
  home.packages = [
    bluetui-widget
  ];
}
