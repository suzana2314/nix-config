{ config, pkgs, ... }:
{
  services.swaync = {
    enable = true;
    package = pkgs.unstable.swaynotificationcenter;
    settings = {
      ignore-gtk-theme = true;
      layer = "overlay";
      control-center-height = 2;
      control-center-margin-bottom = 10;
      control-center-margin-left = 0;
      control-center-margin-right = 10;
      control-center-margin-top = 10;
      control-center-width = 400;
      layer-shell = true;
      layer-shell-cover-screen = true;
      cssPriority = "user";
      control-center-positionX = "right";
      control-center-positionY = "center";
      fit-to-screen = true;
      hide-on-action = false;
      hide-on-clear = false;
      image-visibility = "when-available";
      keyboard-shortcuts = true;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      notification-icon-size = 40;
      notification-inline-replies = true;
      notification-window-width = 500;
      positionX = "right";
      positionY = "top";
      script-fail-notify = true;
      timeout = 10;
      timeout-critical = 0;
      timeout-low = 5;
      transition-time = 100;

      widget-config = {
        mpris = {
          image-radius = 12;
          image-size = 96;
        };

        title = {
          text = "Notifications";
          button-text = "󰎟";
          clear-all-button = true;
        };

        notifications = {
          clear-all-button = true;
        };

        volume = {
          label = "";
          show-per-app = true;
          show-per-app-icon = true;
          show-per-app-label = false;
        };
      };

      widgets = [
        "title"
        "notifications"
        "mpris"
        "volume"
      ];
    };
    style =
      let
        inherit (config.colorScheme) palette;
        inherit (config.fontProfiles) monospace;
      in
      ''
        * {
          font-family: ${monospace.name};
        }

        .control-center {
          background: #${palette.base00};
          border-radius: 10px;
          border: none;
          margin: 2px;
          box-shadow: 0 2px 6px rgba(0, 0, 0, 0.4);
        }

        .control-center-list {
          background: transparent;
        }

        .control-center-list-placeholder {
          opacity: .5;
        }

        /* Notification rows in control center */
        .control-center .notification-row {
          outline: none;
          padding: 0;
        }

        .control-center .notification-row .notification-background,
        .control-center .notification-row .notification-background .notification.critical {
          background-color: transparent;
          border-radius: 10px;
          margin: 0;
          padding: 4px;
          border: none;
        }

        .control-center .notification-row .notification-background .notification.critical {
          color: #${palette.base08};
        }

        .control-center .notification-row .notification-background .notification .notification-content {
          margin: 10px;
          padding: 4px;
          color: #${palette.base05};
        }

        .control-center .notification-row .notification-background .notification > *:last-child > * {
          min-height: 1em;
        }

        .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action {
          background: #${palette.base02};
          color: #${palette.base05};
          border-radius: 8px;
          margin: 4px;
          padding: 6px;
          border: none;
        }

        .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
          background: #${palette.base03};
        }

        .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
          background-color: #${palette.base0D};
        }

        .control-center .notification-row .notification-background .close-button {
          background: transparent;
          border-radius: 8px;
          color: #${palette.base05};
          margin: 4px;
          padding: 4px;
        }

        .control-center .notification-row .notification-background .close-button:hover {
          background-color: #${palette.base02};
        }

        .control-center .notification-row .notification-background .close-button:active {
          background-color: #${palette.base08};
        }

        /* Notification groups */
        .notification-group {
          background: transparent;
        }

        .notification-group-headers {
          font-weight: bold;
          color: #${palette.base0C};
          background: transparent;
        }

        .notification-group-icon {
          opacity: 0;
          min-width: 0;
          min-height: 0;
        }

        .notification-group-headers > label {
          opacity: 0;
          min-width: 0;
          min-height: 0;
        }

        .notification-group-collapse-button,
        .notification-group-close-all-button {
          background: transparent;
          color: #${palette.base05};
          margin: 2px;
          border-radius: 8px;
          padding: 4px;
        }

        .notification-group-collapse-button:hover,
        .notification-group-close-all-button:hover {
          background: #${palette.base02};
        }

        /* Progress bars */
        progressbar, progress, trough {
          border-radius: 8px;
        }

        progressbar {
          background-color: #${palette.base02};
        }

        .notification.critical progress {
          background-color: #${palette.base08};
        }

        .notification.low progress,
        .notification.normal progress {
          background-color: #${palette.base0D};
        }

        /* Floating notifications */
        .floating-notifications.background .notification-row {
          outline: none;
          margin: 10px;
          padding: 0;
        }

        .floating-notifications.background .notification-row .notification-background {
          background: #${palette.base00};
          box-shadow: 0 2px 8px rgba(0, 0, 0, 0.5);
          border-radius: 10px;
          margin: 0;
          padding: 0;
        }

        .floating-notifications.background .notification-row .notification-background .notification {
          padding: 10px;
          border-radius: 10px;
          background: transparent;
        }

        .floating-notifications.background .notification-row .notification-background .notification.critical {
          color: #${palette.base08};
        }

        .floating-notifications.background .notification-row .notification-background .notification .notification-content {
          margin: 4px;
          color: #${palette.base05};
        }

        .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * {
          min-height: 2.5em;
        }

        .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action {
          border-radius: 8px;
          background-color: #${palette.base02};
          color: #${palette.base05};
          margin: 4px;
          padding: 6px;
        }

        .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
          background-color: #${palette.base03};
        }

        .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
          background-color: #${palette.base0D};
        }

        .floating-notifications.background .notification-row .notification-background .close-button {
          margin: 4px;
          padding: 4px;
          border-radius: 8px;
          background-color: transparent;
        }

        .floating-notifications.background .notification-row .notification-background .close-button:hover {
          background-color: #${palette.base02};
        }

        .floating-notifications.background .notification-row .notification-background .close-button:active {
          background-color: #${palette.base08};
        }

        .image {
          margin: 4px;
          border-radius: 8px;
        }

        .summary {
          font-weight: 800;
          font-size: 1rem;
          color: #${palette.base06};
        }

        .body {
          font-size: 0.9rem;
          color: #${palette.base05};
        }

        /*** Widgets ***/

        .widget-title {
          margin: 8px;
          font-size: 1.5rem;
          background: transparent;
          color: #${palette.base0C};
        }

        .widget-title > button {
          font-size: 16px;
          background: #${palette.base01};
          color: #${palette.base0D};
          text-shadow: none;
          box-shadow: none;
          border-radius: 12px;
        }

        .widget-title > button:hover {
          background: #${palette.base02};
          color: #${palette.base07};
          animation: ws_hover 20s ease-in-out 1;
          transition: all 0.6s cubic-bezier(0.25, 0.8, 0.25, 1);
        }

        .widget-mpris {
          font-family: "JetBrains Mono Nerd Font";
          border: 0px;
          margin: 0 14px 14px 14px;
          padding: 0;
        }

        .widget-mpris-player {
          border-radius: 10px;
          border: none;
          box-shadow: none;
          margin: 0;
          padding: 0;
        }

        .widget-volume {
          background-color: transparent;
          font-size: 15px;
          margin-left: 10px;
          margin-right: 10px;
          border: 0px solid transparent;
        }

        .widget-volume {
          border-radius: 20px 20px 0px 0px;
          padding-bottom: 5px;
        }

        .widget-volume trough highlight {
          padding-top: 1px;
          background: #${palette.base0D};
          border: none;
          border-radius: 20px;
        }

        .widget-volume trough slider {
          padding: 1px;
          background: #${palette.base0D};
          border: none;
          box-shadow: none;
        }

        .widget-label>label {
          color: #${palette.base0C};
        }
      '';
  };
}
