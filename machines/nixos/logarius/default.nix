{ inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-intel-gen1
    inputs.disko.nixosModules.disko

    ./hardware-configuration.nix
    ./disks.nix

    ../../common/users/suz # main user
    ../../common/core
    ../../common/options/audio
    ../../common/options/wireless
    ../../common/options/systemd-bootloader
    ../../common/options/wayland
    ../../common/options/greetd
    ../../common/options/printing
    ../../common/options/virtualisation
    ../../common/options/yubikey
    ../../common/options/localsend
  ];

  boot.initrd.systemd.enable = true;

  systemd.network.wait-online.enable = false;

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  boot.initrd.luks.devices = {
    cryptroot = {
      device = "/dev/disk/by-partlabel/luks";
      allowDiscards = true;
    };
  };

  services.fprintd.enable = true;

  networking.hostName = "logarius";
  networking.firewall.enable = true;

  programs.ssh.startAgent = true;
  programs.nix-ld.enable = true;

  system.stateVersion = "25.11";
}
