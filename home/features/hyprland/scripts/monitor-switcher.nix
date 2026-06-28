{
  pkgs,
  ...
}:
let
  monitor-switcher = pkgs.writeShellApplication {
    name = "monitor-switcher";
    runtimeInputs = [
      pkgs.hyprland
      pkgs.libnotify
    ];
    text = ''

      STATE_FILE="$HOME/.cache/monitor-state"

      if [ -f "$STATE_FILE" ]; then
          CURRENT_STATE=$(cat "$STATE_FILE")
      else
          CURRENT_STATE="dual"
      fi

      if [ "$CURRENT_STATE" = "dual" ]; then
          echo "Switching to single monitor only..."

          hyprctl keyword monitor "desc:BOE 0x08E8,disable"

          echo "single" > "$STATE_FILE"

          notify-send "Monitor Setup" "Switched to single monitor config" -t 2000
      else
          echo "Switching back to dual monitor setup..."

          hyprctl keyword monitor "desc:BOE 0x08E8,1920x1080@120,2560x834,1"

          echo "dual" > "$STATE_FILE"

          notify-send "Monitor Setup" "Switched back to dual monitors" -t 2000
      fi

    '';
  };
in
{
  home.packages = [
    monitor-switcher
  ];

}
