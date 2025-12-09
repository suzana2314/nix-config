{ pkgs, ... }:
{
  programs.hyprland.enable = true;
  security.pam.services.hyprlock = { };

  services.displayManager.ly = {
    enable = true;
    x11Support = false;
    settings = {
      blank_password = true;
      hide_key_hints = true;
      session_log = null;
    };
  };

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];
}
