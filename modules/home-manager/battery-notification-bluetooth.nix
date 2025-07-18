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
  bluetooth-notify-pkg = pkgs.writeShellApplication {
    name = "bluetooth-notify";
    text = ''
      LOW_BATTERY_THRESHOLD=${toString config.services.batteryNotifyBluetooth.threshold}

         get_connected_devices() {
             # first check all the devices then check which ones are connected
             bluetoothctl devices | awk '{print $2}' | while read -r device; do
                 if bluetoothctl info "$device" | grep -q "Connected: yes"; then
                     echo "$device"
                 fi
             done
         }
         get_device_name() {
             local device_address=$1
             bluetoothctl info "$device_address" | grep "Name:" | awk -F ': ' '{print $2}'
         }

         get_battery_level() {
             local device_address=$1
             bluetoothctl info "$device_address" | grep "Battery Percentage" | grep -oP '\(\d+\)' | tr -d '()'
         }

         send_notification() {
             local device_name=$1
             local battery_level=$2
             notify-send -u critical "Low Battery" "Your Bluetooth device ($device_name) battery is low: $battery_level%"
         }

         connected_devices=$(get_connected_devices)

         if [ -z "$connected_devices" ]; then
             echo "No connected Bluetooth devices found."
             exit 0
         fi

         for device in $connected_devices; do
             battery_level=$(get_battery_level "$device")
             device_name=$(get_device_name "$device")

             # Check if the battery level is a valid integer
             if [[ "$battery_level" =~ ^[0-9]+$ ]]; then
                 if (( battery_level <= LOW_BATTERY_THRESHOLD )); then
                     send_notification "$device_name" "$battery_level"
                 fi
             else
                 echo "Failed to retrieve valid battery level for $device_name. Output: '$battery_level'"
             fi
         done
    '';
  };
in
{
  options = {
    services.batteryNotifyBluetooth = {
      enable = mkEnableOption "Enable bluetooth devices battery notification service";

      threshold = mkOption {
        type = types.int;
        default = 20;
        description = "Battery percentage threshold for low battery notifications";
      };
    };
  };

  config = mkIf config.services.batteryNotifyBluetooth.enable {
    systemd.user.services.bluetooth-battery-monitor = {
      Unit = {
        Description = "Monitor Bluetooth device battery levels";
        After = [ "bluetooth.service" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${bluetooth-notify-pkg}/bin/bluetooth-notify";
      };
    };

    systemd.user.timers.bluetooth-battery-monitor = {
      Unit = {
        Description = "Timer for Bluetooth battery monitor";
      };
      Timer = {
        OnBootSec = "1m";
        OnUnitActiveSec = "10m";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
