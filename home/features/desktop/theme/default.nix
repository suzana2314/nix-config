{
  inputs,
  pkgs,
  config,
  ...
}:
let
  inherit (config.scheme) theme polarity fonts;

in
{
  imports = [
    inputs.stylix.homeModules.stylix
  ];
  stylix = {
    enable = true;
    base16Scheme = theme;
    autoEnable = false;
    enableReleaseChecks = false;
    polarity = polarity;
    fonts = {
      monospace = {
        package = fonts.monospace.package;
        name = fonts.monospace.name;
      };
      sansSerif = {
        package = fonts.sansSerif.package;
        name = fonts.sansSerif.name;
      };
      serif = config.stylix.fonts.sansSerif;
    };
    targets = {
      gtk = {
        enable = true;
        fonts.enable = false;
      };
      qt = {
        enable = true;
        standardDialogs = "xdgdesktopportal";
      };
      gnome.enable = true; # -> fixes dark mode?
    };
  };

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.quintom-cursor-theme;
      name = "Quintom_Ink";
      size = 16;
    };
    iconTheme = {
      package = pkgs.gruvbox-plus-icons.override { folder-color = "grey"; };
      name = "Gruvbox-Plus-Dark";
    };
  };
}
