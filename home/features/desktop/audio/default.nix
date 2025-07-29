{ pkgs, ... }:
{
  services.mpris-proxy.enable = true;
  home.packages = with pkgs; [
    pavucontrol
  ];
}
