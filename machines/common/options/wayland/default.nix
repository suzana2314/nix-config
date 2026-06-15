{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    package = pkgs.unstable.hyprland;
  };
  security.pam.services.hyprlock = { };
}
