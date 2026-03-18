{ config, pkgs, ... }:
{
  imports = [
    ./scripts
  ];

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "bottom";
        position = "top";
        height = 50;
        exclusive = true;
        passthrough = false;

        modules-left = [
          "custom/padd"
          "clock#date"
          "custom/separator"
          "clock#time"
          "custom/padd"
        ];

        modules-center = [
          "hyprland/workspaces"
        ];

        modules-right = [
          "custom/padd"
          "wireplumber"
          "custom/separator"
          "hyprland/language"
          "custom/separator"
          "custom/vpn"
          "network"
          "custom/separator"
          "bluetooth"
          "custom/separator"
          "battery"
          "custom/padd"
        ];

        "custom/vpn" = {
          format = "{}";
          interval = 2;
          exec = ''
            WG_INTERFACE=$(ip link show | grep -E '^[0-9]+: wg' | cut -d: -f2 | tr -d ' ')
            if [ -n "$WG_INTERFACE" ]; then
              echo "󰿂 "
            fi
          '';
        };

        "bluetooth" = {
          format = "bt";
          format-disabled = "bt";
          format-connected = "bt";
          on-click = "widgetify -s 500x800 -P right bluetui";
        };

        "custom/padd" = {
          format = " ";
          interval = "once";
          tooltip = false;
        };

        "custom/separator" = {
          format = "|";
          interval = "once";
          tooltip = false;
        };

        "hyprland/workspaces" = {
          format = "<span>{icon}</span>";
          tooltip = false;
          format-icons = {
            active = "";
            default = "";
          };
          disable-scroll = true;
          rotate = 0;
          all-outputs = true;
          active-only = true;
          sort-by = "number";
          on-click = "activate";
          separate-outputs = false;
          persistent-workspaces = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
            "5" = [ ];
          };
        };

        "clock#date" = {
          format = "{:%a, %d of %B}";
          rotate = 0;
          format-alt = "{:%a, %d of %B}";
          tooltip = false;
          on-click = "widgetify -s 1000x800 -P left khal interactive";
        };

        "clock#time" = {
          format = "{:%H:%M}";
          rotate = 0;
          format-alt = "{:%H:%M}";
          tooltip = false;
          on-click = "widgetify -s 1000x800 -P left khal interactive";
        };

        "wireplumber" = {
          format = "{volume} %";
          rotate = 0;
          format-muted = "muted";
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-click = "widgetify -s 1000x800 -P right wiremix";
          tooltip = false;
          scroll-step = 1;
        };

        "network" = {
          rotate = 0;
          format-wifi = "{essid}";
          format-ethernet = "eth";
          format-linked = "(No IP)";
          format-disconnected = "down";
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

        "battery" = {
          format = "{capacity}%";
          tooltip = false;
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
          font-family: ${monospace.name};
          font-size: 14px;
          min-height: 0px;
        }

        window#waybar {
            background-color: transparent;
        }

        window#waybar > box {
            border-radius: 10px;
            margin: 10px 10px 3px 10px;
            background-color: #${palette.base00};
            box-shadow: 0px 0px 2px 1px rgba(26, 26, 26, 0.85);
        }

        #workspaces button {
          color: #${palette.base03};
          padding-left: 6px;
        }

        #workspaces button.active {
          color: #${palette.base0A};
        }

        #workspaces button:not(.active):not(.empty):not(:hover) {
          color: #${palette.base06};
        }

        #clock.date,
        #clock.time,
        #bluetooth,
        #bluetooth.disabled,
        #bluetooth.connected,
        #network,
        #network.disconnected,
        #battery,
        #language,
        #workspaces,
        #wireplumber,
        #custom-separator {
          color: #${palette.base0C};
          padding-left: 4px;
          padding-right: 4px;
        }

        #custom-vpn {
          font-size: 16px;
        }

        #language {
          color: #${palette.base0E};
        }

        #bluetooth,
        #battery.charging {
          color: #${palette.base0D};
        }

        #network,
        #battery.full,
        #battery.not-charging,
        #bluetooth.connected {
          color: #${palette.base0B};
        }

        #custom-vpn,
        #bluetooth.disabled,
        #network.disconnected {
          color: #${palette.base08};
        }

        #wireplumber {
          color:  #${palette.base0A}
        }

        #custom-separator {
          color: #${palette.base01};
        }

        #battery.discharging {
          color: #${palette.base09};
        }
      '';
  };

  home.packages = with pkgs; [
    bluetui
    wiremix
  ];
}
