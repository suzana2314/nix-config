{
  inputs,
  config,
  pkgs,
  ...
}:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  sopsFile = "${builtins.toString inputs.nix-secrets}/sops/${config.networking.hostName}.yaml";
in
{
  users.mutableUsers = false;
  sops.secrets.brb-password = {
    inherit sopsFile;
    neededForUsers = true;
  };

  users.users.brb = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.brb-password.path;
    shell = pkgs.zsh;
    extraGroups = ifExists [
      "wheel"
      "networkmanager"
      "docker"
      "podman"
      "dialout"
    ];
  };

  home-manager.users.brb = import ../../../../home/brb/${config.networking.hostName}.nix;
  home-manager.useUserPackages = true;
}
