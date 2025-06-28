{ inputs
, config
, pkgs
, ...
}:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  sopsFile = "${builtins.toString inputs.nix-secrets}/sops/shared.yaml";
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
  };

  home-manager.users.suz = import ../../../../homemanager/${config.networking.hostName}.nix;
  home-manager.useUserPackages = true;
}
