{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  sopsFile = "${toString inputs.nix-secrets}/sops/shared.yaml";

  sshKeys =
    let
      keyPath = ../../../../keys/ssh;
    in
    if lib.pathExists keyPath then
      lib.pipe (lib.filesystem.listFilesRecursive keyPath) [
        (lib.filter (file: lib.hasSuffix ".pub" (toString file)))
        (map (file: lib.trim (builtins.readFile file)))
      ]
    else
      [ ];
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

    openssh.authorizedKeys.keys = sshKeys;
  };

  home-manager.users.suz = import ../../../../home/suz/${config.networking.hostName}.nix;
  home-manager.useUserPackages = true;
}
