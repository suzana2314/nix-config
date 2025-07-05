{ inputs, config, pkgs, ... }:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  sopsFile = "${builtins.toString inputs.nix-secrets}/sops/shared.yaml";
in
{
  users.mutableUsers = false;
  sops.secrets.zez-password = {
    inherit sopsFile;
    neededForUsers = true;
  };

  users.users.zez = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.zez-password.path;
    shell = pkgs.zsh;
    extraGroups = ifExists [
      "networkmanager"
    ];
  };

  home-manager.users.zez = import ../../../../homemanager/zez/${config.networking.hostName}.nix;
  home-manager.useUserPackages = true;
}
