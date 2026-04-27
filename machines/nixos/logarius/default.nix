{ inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko

    ./hardware-configuration.nix
    ./disks.nix

    ../../common/users/suz # main user
    ../../common/core
    ../../common/options/power
    ../../common/options/audio
    ../../common/options/wireless
    ../../common/options/grub-bootloader
    ../../common/options/wayland
    ../../common/options/printing
    ../../common/options/virtualisation
    ../../common/options/yubikey
  ];

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

  networking.hostName = "logarius";
  networking.firewall.enable = true;

  programs.ssh.startAgent = true;
  programs.nix-ld.enable = true;

  system.stateVersion = "25.11";
}
