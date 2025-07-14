{ pkgs, ... }:
{
  # required for hyprland setup (I dont like the flake)
  programs.hyprland.enable = true;

  security.pam.services.hyprlock = { };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "${import ./sddm-sugar { inherit pkgs; }}";
  };

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];

  environment.systemPackages = with pkgs; [
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects
  ];
}
