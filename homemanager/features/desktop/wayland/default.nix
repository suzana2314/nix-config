{ pkgs, config, ... }:
{
  home = {
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      # NIXOS_OZONE_WL = "1";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      GDK_BACKEND = "wayland";
      GTK_USE_PORTAL = "1";
    };

    packages = with pkgs; [
      wl-clipboard
      libnotify
    ];

    # These are needed for some compatibility with xwayland apps
    pointerCursor = {
      inherit (config.gtk.cursorTheme) name;
      inherit (config.gtk.cursorTheme) package;
      inherit (config.gtk.cursorTheme) size;
      gtk.enable = true;
      x11.enable = true;
      x11.defaultCursor = config.gtk.cursorTheme.name;
    };
  };

  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-wlr
  ];
}
