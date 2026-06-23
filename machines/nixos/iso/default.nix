{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  genPubKeyList =
    user:
    let
      keyPath = ../../common/users/${user}/keys/ssh;
    in
    if (lib.pathExists keyPath) then
      lib.lists.forEach (lib.filesystem.listFilesRecursive keyPath) (key: lib.readFile key)
    else
      [ ];
  superKeys = genPubKeyList "super";
in
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
  ];

  networking.hostName = "iso";

  isoImage.squashfsCompression = "zstd -Xcompression-level 3";

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    config.allowUnfree = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.qemuGuest.enable = true;

  boot.supportedFilesystems = lib.mkForce [
    "btrfs"
    "vfat"
  ];

  # ssh
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
  users.users.root.openssh.authorizedKeys.keys = superKeys;

  # mdns so that we can login without the ip address
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
}
