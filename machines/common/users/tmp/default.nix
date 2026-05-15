{
  lib,
  config,
  pkgs,
  ...
}:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;

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
  # This is a temp user used for bootstrapping a system
  users.users.tmp = {
    isNormalUser = true;
    initialPassword = "hunter2";
    shell = pkgs.zsh;
    extraGroups = ifExists [
      "wheel"
      "networkmanager"
      "dialout"
    ];

    openssh.authorizedKeys.keys = superKeys;
  };
}
