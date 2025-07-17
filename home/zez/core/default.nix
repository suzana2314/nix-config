{ lib, pkgs, config, outputs, ... }:
let
  inherit (lib) mkDefault;
in
{
  imports = [
    ../../features/zsh
  ] ++ (builtins.attrValues outputs.homeModules);

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  home = {
    username = mkDefault "zez";
    homeDirectory = mkDefault "/home/${config.home.username}";
    stateVersion = mkDefault "25.05";
  };

  # some utils
  home.packages = with pkgs; [
    unzip
    htop
  ];
}
