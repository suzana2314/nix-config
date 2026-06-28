{ pkgs, ... }:
let
  hyprlock-restart = pkgs.writeShellApplication {
    name = "hyprlock-restart";
    runtimeInputs = [
      pkgs.hyprland
      pkgs.hyprlock
    ];
    text = ''
      hyprctl --instance 0 'keyword misc:allow_session_lock_restore 1'
      sleep 0.5
      hyprctl --instance 0 'dispatch exec hyprlock'
    '';
  };
in
{
  home.packages = [
    hyprlock-restart
  ];
}
