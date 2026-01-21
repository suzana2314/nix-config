{ inputs, pkgs, ... }:
let
  freecadWayland = pkgs.symlinkJoin {
    name = "freecad-wayland-fix";
    paths = [
      pkgs.freecad-wayland
    ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/FreeCAD \
        --prefix MESA_LOADER_DRIVER_OVERRIDE : zink \
        --prefix __EGL_VENDOR_LIBRARY_FILENAMES : ${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json \
    '';
  };
in
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
    ../features/git
    ../features/direnv
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
      description = "BOE 0x08E8";
      width = 1920;
      height = 1080;
      refreshRate = 120;
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
    batteryNotify.enable = true;
    batteryNotifyBluetooth.enable = true;
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
    unstable.vscode
    unstable.obsidian
    unstable.prusa-slicer
    # unstable.freecad-wayland
    freecadWayland
    libreoffice
    sqldeveloper
  ];
}
