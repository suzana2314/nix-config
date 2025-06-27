{
  # TODO replace these imports with the lib.custom
  monitors = import ./monitors.nix;
  fonts = import ./fonts.nix;
  wallpaper = import ./wallpaper.nix;
  battery-notification = import ./battery-notification.nix;
  battery-notification-bluetooth = import ./battery-notification-bluetooth.nix;
}
