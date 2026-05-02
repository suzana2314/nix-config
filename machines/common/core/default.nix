{
  inputs,
  outputs,
  pkgs,
  lib,
  ...
}:
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

  security = {
    doas.enable = lib.mkDefault false;
    sudo = {
      enable = lib.mkDefault true;
    };
  };

  # quick fix for: CVE-2026-31431
  boot.kernelPackages = lib.mkIf (lib.versionOlder pkgs.linux.version "6.18.22") (
    lib.mkDefault pkgs.linuxPackages_6_18
  );

  environment.systemPackages = with pkgs; [
    rsync
    nitch
  ];
}
