{ inputs, pkgs, ... }:
{
  imports = [
    inputs.nix-colors.homeManagerModules.default
    ../features/nvim
    ../features/desktop/alacritty
    ./core
  ];

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;

  fontProfiles = {
    enable = true;
    monospace = {
      name = "JetBrainsMono Nerd Font";
      size = 15;
      package = pkgs.nerd-fonts.jetbrains-mono;
    };
    regular = {
      name = "Ubuntu Sans";
      package = pkgs.nerd-fonts.ubuntu-sans;
    };
  };

  home.packages = with pkgs; [
    # util
    vlc
    # apps
    unstable.firefox
    libreoffice
    old.freecad-wayland
    old.prusa-slicer # broke with new release
  ];

}
