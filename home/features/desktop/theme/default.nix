{ pkgs, config, ... }:

let
  gruvbox-theme = pkgs.gruvbox-gtk-theme.override {
    colorVariants = [ "dark" ];
    themeVariants = [ "yellow" ];
    sizeVariants = [ "standard" ];
    tweakVariants = [ ];
    iconVariants = [ "Dark" ];
  };
in
{
  gtk = {
    enable = true;
    gtk2 = {
      configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    };
    cursorTheme = {
      package = pkgs.quintom-cursor-theme;
      name = "Quintom_Ink";
      size = 16;
    };
    theme = {
      name = "Gruvbox-Yellow-Dark";
      package = gruvbox-theme;
    };
    iconTheme = {
      package = pkgs.gruvbox-plus-icons.override { folder-color = "grey"; };
      name = "Gruvbox-Plus-Dark";
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  qt = {
    enable = true;
    platformTheme = {
      name = "gtk3";
      package = [
        # QT 5
        (pkgs.libsForQt5.qtstyleplugins.overrideAttrs (old: {
          # Make qtstyleplugins' gtk2 platform theme activate if QT_QPA_PLATFORMTHEME=gtk3
          patches = (old.patches or [ ]) ++ [ ./qtstyleplugins-gtk3-key.patch ];
        }))
        # QT 6
        pkgs.qt6.qtbase
      ];
    };
  };

  # ENABLE IF ABOVE CAUSES ISSUES
  #qt = {
  #  enable = true;
  #  platformTheme.name = "qtct";
  #  style.name = "kvantum";
  #};

  #xdg.configFile = {
  #  "Kvantum/kvantum.kvconfig".text = ''
  #    [General]
  #    theme=Gruvbox-Dark-Brown
  #  '';

  #  "Kvantum/Gruvbox-Dark-Brown".source = "${pkgs.gruvbox-kvantum}/share/Kvantum/Gruvbox-Dark-Brown";
  #};

  home.packages = [
    gruvbox-theme
  ];
}
