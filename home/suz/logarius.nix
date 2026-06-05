{ pkgs, ... }:
{
  imports = [
    ../features/desktop/ghostty
    ../features/desktop/discord
    ../features/desktop/notifications
    ../features/desktop/hyprland
    ../features/desktop/theme
    ../features/desktop/waybar
    ../features/desktop/wayland
    ../features/desktop/wofi
    ../features/desktop/neovim
    ../features/desktop/calendar
    ../features/desktop/subtui
    ../features/desktop/firefox
    ../features/bat
    ../features/git
    ../features/direnv
    ../features/env
    ../features/sops
    ../features/yubikey
    ../features/ssh
    ../features/gpg
    ../features/xdg
    ./core
  ];

  scheme = {
    wallpaper = {
      url = "https://gruvbox-wallpapers.pages.dev/wallpapers/photography/mountains2.jpg";
      hash = "sha256-hp9cxCpZsDYKxUUSuec2wZyv9/N93Cw6ENTHGxKap9Q=";
    };
    theme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    polarity = "dark";
    cursor = {
      name = "Quintom_Ink";
      package = pkgs.quintom-cursor-theme;
      size = 16;
    };
    icons = {
      dark = "Gruvbox-Plus-Dark";
      package = pkgs.gruvbox-plus-icons.override { folder-color = "grey"; };
    };
    fonts = {
      monospace = {
        name = "JetBrainsMono NF";
        package = pkgs.nerd-fonts.jetbrains-mono;
      };
      sansSerif = {
        name = "Ubuntu Sans";
        package = pkgs.ubuntu-sans;
      };
    };
  };

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
      description = "AU Optronics 0x403D";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      x = 2560;
      y = 834;
      scale = 1.0;
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
      description = "Samsung Electric Company LC27G5xT H4ZR704887";
      width = 2560;
      height = 1440;
      refreshRate = 144;
      x = 0;
      y = 0;
      scale = 1.0;
      bitdepth = 10;
      primary = true;
      workspaces = [
        "1"
        "2"
        "3"
        "4"
        "5"
      ];
    }
  ];

  services = {
    batsignal.enable = true;
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
    unstable.obsidian
    subtui
  ];
}
