{
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-hardware.nixosModules.lenovo-legion-15ach6h-hybrid

    ./hardware-configuration.nix
    ../../common/users/suz # main user
    ../../common/core
    ../../common/options/power
    ../../common/options/audio
    ../../common/options/wireless
    ../../common/options/grub-bootloader # for dual boot
    ../../common/options/wayland
    ../../common/options/printing
    ../../common/options/virtualisation
    ../../common/options/nvidia
    ../../common/options/steam
  ];

  systemd.network.wait-online.enable = false;

  networking.hostName = "master";
  networking.firewall.enable = true;

  boot.supportedFilesystems = [ "ntfs" ]; # for external hdd

  services = {
    devmon.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
  };

  # FIXME: this should be in a separate file!
  yubikey = {
    enable = true;
    user = config.users.users.suz.name;
  };

  programs.ssh.startAgent = true; # FIXME: should this be started with the yubikey module already in place?
  programs.nix-ld.enable = true;

  system.stateVersion = "24.05";
}
