{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    package = pkgs.unstable.hyprland;
  };
  security.pam.services.hyprlock = { };
}
