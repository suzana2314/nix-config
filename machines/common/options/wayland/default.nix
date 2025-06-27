{ pkgs, ... }:
{
  # required for hyprland setup (I dont like the flake)
  programs.hyprland.enable = true;

  security.pam.services.hyprlock = { };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "${import ./sddm-sugar-custom.nix { inherit pkgs; }}";
  };

  # my sddm theme needs these packages
  environment.systemPackages = with pkgs; [
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects
  ];
}
