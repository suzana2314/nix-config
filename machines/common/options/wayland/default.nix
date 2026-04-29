{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    package = pkgs.unstable.hyprland;
  };
  security.pam.services.hyprlock = { };

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];
}
