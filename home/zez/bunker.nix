{ pkgs, ... }:
{
  imports = [
    ./core
  ];

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
    libreoffice
    unstable.firefox
    unstable.freecad-wayland
    unstable.prusa-slicer
  ];

}
