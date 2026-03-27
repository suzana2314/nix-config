{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  sopsFile = "${builtins.toString inputs.nix-secrets}/sops/shared.yaml";

  genPubKeyList =
    user:
    let
      keyPath = ../${user}/keys/ssh;
    in
    if (lib.pathExists keyPath) then
      lib.lists.forEach (lib.filesystem.listFilesRecursive keyPath) (key: lib.readFile key)
    else
      [ ];

  # list of ssh yubikeys that will allow access to any system
  superKeys = genPubKeyList "super";
in
{
  users.mutableUsers = false;
  sops.secrets.suz-password = {
    inherit sopsFile;
    neededForUsers = true;
  };

  users.users.suz = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.suz-password.path;
    shell = pkgs.zsh;
    extraGroups = ifExists [
      "wheel"
      "networkmanager"
      "docker"
      "podman"
      "dialout"
    ];

    openssh.authorizedKeys.keys = superKeys;
  };

  home-manager.users.suz = import ../../../../home/suz/${config.networking.hostName}.nix;
  home-manager.useUserPackages = true;
}
