{
  inputs,
  outputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  hasPersistence = config.environment ? persistence."/persist";
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./nix.nix
    ./zsh.nix
    ./sops.nix
    ./locale.nix
    ./xdg.nix
    ./editor.nix
    ./network.nix
  ]
  ++ (builtins.attrValues outputs.nixosModules);

  home-manager.useGlobalPkgs = true;
  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
  };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
  };

  # this is to make sure there are always host keys
  services.openssh = {
    generateHostKeys = true;
    hostKeys = [
      {
        path = "${lib.optionalString hasPersistence "/persist"}/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];

  };

  security = {
    doas.enable = lib.mkDefault false;
    sudo = {
      enable = lib.mkDefault true;
    };
  };

  environment.systemPackages = with pkgs; [
    rsync
    nitch
  ];
}
