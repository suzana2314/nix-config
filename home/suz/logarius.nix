{ inputs, pkgs, ... }:
{
  imports = [
    inputs.nix-colors.homeManagerModules.default
    ../features/desktop/alacritty
    ../features/desktop/discord
    ../features/desktop/notifications
    ../features/desktop/gtk
    ../features/desktop/hyprland
    ../features/desktop/qt
    ../features/desktop/waybar
    ../features/desktop/wayland
    ../features/desktop/wofi
    ../features/desktop/neovim
    ../features/desktop/calendar
    ../features/desktop/subtui
    ../features/git
    ../features/direnv
    ../features/env
    ../features/sops
    ../features/yubikey
    ../features/ssh
    ../features/gpg
    ./core
  ];

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;

  wallpaper = "~/pictures/wallpaper/road.jpg";

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
      description = "";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      x = 2560;
      y = 834;
      scale = 1.0;
      primary = true;
      workspaces = [
        "1"
        "2"
        "3"
        "4"
        "5"
        "6"
        "7"
        "8"
        "9"
        "10"
      ];
    }
  ];

  services = {
    batteryNotify.enable = true;
    batteryNotifyBluetooth.enable = true;
    yubikey-touch-detector.enable = true;
  };

  home.packages = with pkgs; [
    # util
    unstable.nautilus
    eog
    zathura
    vlc
    lenopow

    # apps
    unstable.firefox
    unstable.obsidian
    subtui
  ];
}
