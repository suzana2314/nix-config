{ pkgs, ... }:
let
  widgetify = pkgs.writeShellApplication {
    name = "widgetify";
    runtimeInputs = [
      pkgs.jq
      pkgs.hyprland
    ];
    text = ''
      set -euo pipefail

      # some defaults

      WINDOW_WIDTH=1000
      WINDOW_HEIGHT=800
      PADDING=10
      STATUSBAR_HEIGHT=40
      POSITION="right"
      usage() {
        echo -e "Usage: $(basename "$0") [-s WxH] [-b STATUSBAR_HEIGHT] [-p PADDING] [-P left|center|right] <application>"
        echo -e ""
        echo -e "Opens a floating terminal window and runs the specified application."
        echo -e ""
        echo -e "Arguments:"
        echo -e "  <application>       The command to run in the new terminal"
        echo -e ""
        echo -e "Options:"
        echo -e "  -s WxH              Window size in pixels (default: ''${WINDOW_WIDTH}x''${WINDOW_HEIGHT})"
        echo -e "  -b STATUSBAR_HEIGHT       Your bar height in pixels (default: $STATUSBAR_HEIGHT)"
        echo -e "  -p PADDING          Window padding in pixels (default: $PADDING)"
        echo -e "  -P left|center|right  Window position (default: $POSITION)"
        echo -e "  -h                  Show this help message"
        echo -e ""
      }

      # some common term emulators
      get_terminal() {
        for term in kitty alacritty ghostty foot; do
          if command -v "$term" &>/dev/null; then
            echo "$term"
            return 0
          fi
        done
        echo "Error: No supported terminal found (kitty, alacritty, ghostty, foot)" >&2
        exit 1
      }

      build_terminal_cmd() {
        local term="$1"
        local class="$2"
        local app="$3"
        case "$term" in
          kitty)    echo "kitty --class $class $app" ;;
          alacritty) echo "alacritty --class $class -e $app" ;;
          ghostty)  echo "ghostty --class $class -e $app" ;;
          foot)     echo "foot --app-id $class $app" ;;
        esac
      }


      # arg parsing

      while getopts "s:b:p:P:h" opt; do
        case $opt in
          s) IFS='x' read -r WINDOW_WIDTH WINDOW_HEIGHT <<< "$OPTARG" ;;
          p) PADDING="$OPTARG" ;;
          b) STATUSBAR_HEIGHT="$OPTARG" ;;
          P) POSITION="$OPTARG" ;;
          h) usage; exit 0 ;;
          *) usage; exit 1 ;;
        esac
      done
      shift $((OPTIND - 1))

      if [ $# -eq 0 ]; then
        usage
        exit 1
      fi

      # validate

      application="$*"
      app_bin="''${application%% *}"
      widget_class="''${app_bin}-widget"

      if ! command -v "$app_bin" &>/dev/null; then
        echo "Error: '$app_bin' is not installed or not in PATH" >&2
        exit 1
      fi

      case "$POSITION" in
        left|center|right) ;;
        *) echo "Error: invalid position '$POSITION' (must be left, center or right)" >&2; exit 1 ;;
      esac

      terminal_bin=$(get_terminal)
      widget_address=$(hyprctl clients -j | jq -r ".[] | select(.class == \"$widget_class\") | .address")

      if [ -n "$widget_address" ]; then
        hyprctl dispatch closewindow "address:$widget_address"
      else
        monitor_info=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true)')
        monitor_name=$(echo "$monitor_info" | jq -r '.name')
        monitor_width=$(echo "$monitor_info" | jq -r '.width')

        case "$POSITION" in
          left) x_pos=$PADDING ;;
          center) x_pos=$(( (monitor_width - WINDOW_WIDTH) / 2 )) ;;
          right) x_pos=$(( monitor_width - WINDOW_WIDTH - PADDING )) ;;
        esac

        y_pos=$((STATUSBAR_HEIGHT + 2 * PADDING))
        term_cmd=$(build_terminal_cmd "$terminal_bin" "$widget_class" "$application")
        hyprctl dispatch exec "[float;monitor $monitor_name;size $WINDOW_WIDTH $WINDOW_HEIGHT;move $x_pos $y_pos] $term_cmd"
      fi
    '';
  };
in
{
  home.packages = [
    widgetify
  ];
}
