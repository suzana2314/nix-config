{ inputs, pkgs, ... }:
{
  imports = [
    inputs.nix-colors.homeManagerModules.default
    ../features/desktop/alacritty
    ../features/desktop/discord
    ../features/desktop/dunst
    ../features/desktop/gtk
    ../features/desktop/hyprland
    ../features/desktop/qt
    ../features/desktop/waybar
    ../features/desktop/wayland
    ../features/desktop/wofi
    ../features/git
    ../features/nvim
    ../features/direnv
    ./core
  ];

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;

  wallpaper = "~/pictures/wallpaper/gruvbox-darker.png";

  fontProfiles = {
    enable = true;
    monospace = {
      name = "JetBrainsMono Nerd Font";
      size = 15;
      package = pkgs.nerd-fonts.jetbrains-mono;
    };
    regular = {
      name = "Ubuntu Sans";
      package = pkgs.ubuntu-sans;
    };
  };

  monitors = [
    {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      refreshRate = 120;
      x = 2550;
      y = 0;
      workspaces = [
        "6"
        "7"
        "8"
        "9"
        "10"
      ];
    }
    {
      name = "HDMI-A-1";
      width = 2550;
      height = 1440;
      refreshRate = 144;
      primary = true;
      workspaces = [
        "1"
        "2"
        "3"
        "4"
        "5"
      ];
    }
    {
      name = "Unknown-1";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      enabled = false;
    }
  ];

  services = {
    batteryNotify.enable = true;
    batteryNotifyBluetooth.enable = true;
  };

  home.packages = with pkgs; [
    # util
    unstable.nautilus
    eog
    bluetui
    pavucontrol
    zathura
    vlc
    lenopow
    sops
    just

    # apps
    unstable.firefox-beta
    unstable.vscode
    unstable.obsidian
    unstable.prusa-slicer
    unstable.prismlauncher
    unstable.freecad-wayland
    libreoffice

  ];
}
