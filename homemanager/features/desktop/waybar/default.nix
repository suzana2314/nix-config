{ config, ... }:
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 50;
        exclusive = true;
        passthrough = false;
        gtk-layer-shell = true;
        margin-left = 10;
        margin-right = 10;
        margin-top = 10;

        modules-left = [
          "custom/padd"
          "custom/l_end"
          "custom/nixos"
          "custom/r_end"
          "custom/padd"
          "custom/l_end"
          "hyprland/workspaces"
          "custom/r_end"
          "custom/padd"
        ];

        modules-center = [
          "custom/padd"
          "custom/l_end"
          "clock"
          "custom/r_end"
          "custom/padd"
        ];

        modules-right = [
          "custom/padd"
          "custom/l_end"
          "custom/audio-icon"
          "wireplumber"
          "custom/r_end"
          "custom/padd"
          "custom/l_end"
          "custom/network-icon"
          "network"
          "custom/r_end"
          "custom/padd"
          "custom/l_end"
          "custom/keyboard-icon"
          "hyprland/language"
          "custom/r_end"
          "custom/padd"
          "custom/l_end"
          "bluetooth"
          "custom/r_end"
          "custom/padd"
          "custom/l_end"
          "custom/battery-icon"
          "battery"
          "custom/r_end"
          "custom/padd"
        ];

        "custom/nixos" = {
          format = "<big> </big>";
          interval = "once";
          tooltip = false;
          on-click = "wofi";
        };

        "custom/audio-icon" = {
          format = " ";
          interval = "once";
          tooltip = false;
        };

        "custom/network-icon" = {
          format = "{}";
          interval = 5;
          exec = ''
            WIFI_INTERFACE=$(ip link show | grep -E '^[0-9]+: wl' | cut -d: -f2 | tr -d ' ')
            ETH_INTERFACE=$(ip link show | grep -E '^[0-9]+: en|^[0-9]+: eth' | cut -d: -f2 | tr -d ' ')
            WG_INTERFACE=$(ip link show | grep -E '^[0-9]+: wg' | cut -d: -f2 | tr -d ' ')
            if [ -n "$WG_INTERFACE" ] && [ -n "$ETH_INTERFACE" ] && [ "$(cat /sys/class/net/$ETH_INTERFACE/operstate 2>/dev/null)" = "up" ]; then
              echo "󰌆 󰈀 "
            elif [ -n "$ETH_INTERFACE" ] && [ "$(cat /sys/class/net/$ETH_INTERFACE/operstate 2>/dev/null)" = "up" ]; then
              echo "󰈀 "
            elif [ -n "$WG_INTERFACE" ] && [ -n "$WIFI_INTERFACE" ] && [ "$(cat /sys/class/net/$WIFI_INTERFACE/operstate 2>/dev/null)" = "up" ]; then
              echo "󰌆 󰤨 "
            elif [ -n "$WIFI_INTERFACE" ] && [ "$(cat /sys/class/net/$WIFI_INTERFACE/operstate 2>/dev/null)" = "up" ]; then
              echo "󰤨 "
            fi
          '';
        };

        "custom/keyboard-icon" = {
          format = "󰌌 ";
          interval = "once";
          tooltip = false;
        };

        "custom/l_end" = {
          format = " ";
          interval = "once";
          tooltip = false;
        };

        "custom/r_end" = {
          format = " ";
          interval = "once";
          tooltip = false;
        };

        "custom/padd" = {
          format = " ";
          interval = "once";
          tooltip = false;
        };

        "hyprland/workspaces" = {
          format = "<span font='12px'>{icon}</span>";
          tooltip = false;
          format-icons = {
            active = "<big>󱨇</big>";
            default = "<big></big>";
          };
          disable-scroll = true;
          rotate = 0;
          all-outputs = true;
          active-only = true;
          sort-by = "number";
          on-click = "activate";
          separate-outputs = false;
          # persistent-workspaces = {
          #   "*" = 10;
          # };
          persistent-workspaces = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
            "5" = [ ];
          };
        };

        "clock" = {
          format = "{:%H:%M / %d %B}";
          rotate = 0;
          format-alt = "{:%H:%M / %d %B}";
          tooltip = false;
        };

        "wireplumber" = {
          format = "{volume} %";
          rotate = 0;
          format-muted = "MUTE";
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          tooltip = false;
          scroll-step = 1;
        };

        "bluetooth" = {
          format = "<span></span> {status}";
          format-disabled = "<span>󰂲</span>";
          format-connected = "<span></span> {num_connections}";
          tooltip-format = "{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_battery_percentage}%";
          on-click = "alacritty -e bluetui";
        };

        "network" = {
          rotate = 0;
          format-wifi = "{essid}";
          format-ethernet = "{ipaddr}";
          format-linked = "󰈀 {ifname} (No IP)";
          format-disconnected = "DISCONNECTED";
          format-alt = "{ifaddr}/{cidr}";
          tooltip = false;
          interval = 2;
        };

        "hyprland/language" = {
          interval = 2;
          rotate = 0;
          format-en = "us";
          format-pt = "pt";
          min-length = 2;
          tooltip = false;
        };

        "custom/battery-icon" = {
          format = "{}";
          interval = 5;
          exec = ''
            BATTERY=$(ls /sys/class/power_supply | grep BAT | head -n 1)

            if [ -n "$BATTERY" ]; then
              CAPACITY=$(cat /sys/class/power_supply/$BATTERY/capacity 2>/dev/null || echo "0")
              STATUS=$(cat /sys/class/power_supply/$BATTERY/status 2>/dev/null || echo "Unknown")

              case "$STATUS" in
                "Charging")
                  echo "󰂄 "
                  ;;
                "Full"|"Not charging")
                  echo " "
                  ;;
                *)
                  if [ "$CAPACITY" -ge 90 ]; then
                    echo "󰁹 "
                  elif [ "$CAPACITY" -ge 80 ]; then
                    echo "󰂂 "
                  elif [ "$CAPACITY" -ge 60 ]; then
                    echo "󰂀 "
                  elif [ "$CAPACITY" -ge 40 ]; then
                    echo "󰁾 "
                  elif [ "$CAPACITY" -ge 20 ]; then
                    echo "󰁼 "
                  else
                    echo "󰁺 "
                  fi
                  ;;
              esac
            else
              echo "󰂃 "
            fi
          '';
          tooltip = false;
        };

        "battery" = {
          format = "{capacity}%";
          tooltip = false;
        };

        "cava" = {
          framerate = 30;
          autosens = 1;
          bars = 14;
          lower_cutoff_freq = 50;
          higher_cutoff_freq = 10000;
          hide_on_silence = true;
          sleep_timer = 1;
          method = "pipewire";
          source = "auto";
          stereo = true;
          reverse = false;
          monstercat = false;
          waves = true;
          noise_reduction = 0.77;
          input_delay = 2;
          bar_delimiter = 0;
          format-icons = [ "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
          actions = {
            on-click-right = "mode";
          };
        };
      };
    };
    style =
      let
        inherit (config.colorScheme) palette;
        inherit (config.fontProfiles) monospace;
      in
      ''
        * {
          border: none;
          border-radius: 0px;
          font-family: ${monospace.name};
          font-size: 14px;
          min-height: 10px;
        }

        window#waybar {
          background: #${palette.base00};
          border-radius: 10px;
        }

        #workspaces button {
          box-shadow: none;
          text-shadow: none;
          padding: 0px;
          border-radius: 8px;
          margin-top: 4px;
          margin-bottom: 4px;
          margin-left: 0px;
          padding-left: 6px;
          padding-right: 10px;
          margin-right: 0px;
          color: #${palette.base03};
          animation: ws_normal 20s ease-in-out 1;
        }

        #workspaces button.active {
          color: #${palette.base0A};
          animation: ws_active 20s ease-in-out 1;
        }

        #workspaces button:not(.active):not(.empty):not(:hover) {
          color: #${palette.base06};
        }

        #workspaces button:hover {
          background: #504945;
          color: #fbf1c7;
          animation: ws_hover 20s ease-in-out 1;
          transition: all 0.6s cubic-bezier(0.25, 0.8, 0.25, 1);
        }

        #workspaces button.active:hover {
          color: #83a598;
        }

        #battery,
        #clock,
        #language,
        #bluetooth,
        #memory,
        #network,
        #wireplumber,
        #temperature,
        #workspaces,
        #custom-l_end,
        #custom-power,
        #custom-audio-icon,
        #custom-network-icon,
        #custom-keyboard-icon,
        #custom-battery-icon,
        #custom-cpu-icon,
        #custom-memory-icon,
        #custom-nixos,
        #custom-r_end {
          color: #${palette.base0C};
          background: #282828;
          opacity: 1;
          margin: 8px 0px 8px 0px;
          padding-left: 4px;
          padding-right: 4px;
        }

        #custom-audio-icon,
        #custom-keyboard-icon,
        #custom-network-icon,
        #custom-battery-icon,
        #custom-memory-icon {
          font-size: 16px;
          color: #${palette.base0D};
        }

        #custom-l_end {
          border-radius: 7px 0 0 7px;
        }

        #custom-r_end {
          border-radius: 0 7px 7px 0;
        }

        #custom-nixos {
          font-size: 16px;
          padding-left: 0px;
          color: #${palette.base0F};
          padding-left: 8px;
        }

        #custom-power {
          font-size: 20px;
          padding-left: 3px;
          padding-right: 7px;
          color: #fb4934;
        }

        #cava {
          color: #${palette.base0F};
          background: #282828;
          margin: 8px 0px 8px 0px;
          padding-left: 8px;
          padding-right: 8px;
          border-radius: 7px;
          transition: ease 0.3s;
        }
      '';
  };
}
