{ pkgs, ... }:

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

  home.packages = [
    gruvbox-theme
  ];
}
