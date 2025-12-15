{
  pkgs,
  config,
  lib,
  ...
}:
let
  primaryMonitor = lib.findFirst (m: m.primary) null config.monitors;
  nonPrimaryMonitors = lib.filter (m: !m.primary) config.monitors;
  workspacesToMove = if primaryMonitor != null then primaryMonitor.workspaces else [ ];
  fallbackMonitor = lib.head nonPrimaryMonitors;

  monitor-listener = pkgs.writeShellApplication {
    name = "monitor-listener";
    runtimeInputs = [
      pkgs.socat
      pkgs.jq
      pkgs.hyprland
    ];
    text = ''
      PRIMARY_MONITOR="${if primaryMonitor != null then primaryMonitor.name else "HDMI-A-1"}"
      FALLBACK_MONITOR="${if fallbackMonitor != null then fallbackMonitor.name else "eDP-1"}"
      WORKSPACES_TO_MOVE=(${lib.concatStringsSep " " (map toString workspacesToMove)})

      move_workspaces_to_monitor() {
          local target_monitor="$1"
          echo "Moving workspaces [''${WORKSPACES_TO_MOVE[*]}] to monitor: $target_monitor"

          for ws in "''${WORKSPACES_TO_MOVE[@]}"; do
              echo "Moving workspace $ws to $target_monitor"
              hyprctl dispatch moveworkspacetomonitor "$ws" "$target_monitor"
          done
      }

      is_primary_connected() {
          hyprctl monitors -j | jq -e --arg monitor "$PRIMARY_MONITOR" '.[] | select(.name == $monitor)' > /dev/null
      }

      handle_monitor_change() {
          echo "Monitor configuration changed, checking status..."
          sleep 1

          if is_primary_connected; then
              echo "Primary monitor ($PRIMARY_MONITOR) is connected"
              move_workspaces_to_monitor "$PRIMARY_MONITOR"
          else
              echo "Primary monitor not connected, using fallback monitor ($FALLBACK_MONITOR)"
              move_workspaces_to_monitor "$FALLBACK_MONITOR"
          fi
      }

      handle() {
          case $1 in
              monitoradded*)
                  echo "Monitor added: $1"
                  handle_monitor_change
                  ;;
              monitorremoved*)
                  echo "Monitor removed: $1"
                  handle_monitor_change
                  ;;
          esac
      }

      echo "Starting Hyprland monitor event listener..."
      echo "Primary monitor: $PRIMARY_MONITOR"
      echo "Fallback monitor: $FALLBACK_MONITOR"
      echo "Workspaces to manage: [''${WORKSPACES_TO_MOVE[*]}]"

      handle_monitor_change

      socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
          handle "$line"
      done
    '';
  };
in
{
  home.packages = [
    monitor-listener
  ];
}
