{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  battery-notify-pkg = pkgs.writeShellApplication {
    name = "battery-notify";
    runtimeInputs = [ pkgs.libnotify ];
    text = ''
      LOW_BATTERY_THRESHOLD=${toString config.services.batteryNotify.threshold}

      get_battery_devices() {
        find /sys/class/power_supply/ -name "BAT*"
      }

      send_notification() {
        notify-send -u critical "Low Battery" "Please plug in your device - battery is below $LOW_BATTERY_THRESHOLD%"
      }

      any_battery_low=false
      for battery in $(get_battery_devices); do
        battery_level=$(cat "$battery/capacity" 2>/dev/null || echo "Unknown")
        battery_status=$(cat "$battery/status" 2>/dev/null || echo "Unknown")
        
        if [[ "$battery_level" != "Unknown" && "$battery_status" != "Unknown" ]]; then
          if (( battery_level <= LOW_BATTERY_THRESHOLD )) && [[ "$battery_status" != "Charging" && "$battery_status" != "Full" ]]; then
            any_battery_low=true
            break
          fi
        fi
      done

      if [[ "$any_battery_low" = true ]]; then
        send_notification
      fi
    '';
  };
in
{
  options = {
    services.batteryNotify = {
      enable = mkEnableOption "Enable battery notification service";

      threshold = mkOption {
        type = types.int;
        default = 20;
        description = "Battery percentage threshold for low battery notification";
      };
    };
  };
  config = mkIf config.services.batteryNotify.enable {
    systemd.user.services.battery-monitor = {
      Unit = {
        Description = "Monitor laptop battery level";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${battery-notify-pkg}/bin/battery-notify";
      };
    };
    systemd.user.timers.battery-monitor = {
      Unit = {
        Description = "Timer for laptop battery monitor";
      };
      Timer = {
        OnBootSec = "1m";
        OnUnitActiveSec = "5m";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
