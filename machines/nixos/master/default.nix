{
  inputs,
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
  ];

  systemd.network.wait-online.enable = false;

  networking.hostName = "master";
  networking.firewall.enable = true;

  hardware.nvidia.prime.amdgpuBusId = "PCI:6:0:0";
  hardware.nvidia.dynamicBoost.enable = false; # FIXME broken in 25.11

  boot.supportedFilesystems = [ "ntfs" ]; # for external hdd

  services = {
    devmon.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
  };

  programs.ssh.startAgent = true;
  programs.nix-ld.enable = true;

  system.stateVersion = "24.05";
}
