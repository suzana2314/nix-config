{ inputs, config, pkgs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ../../common/users/suz # main user

    ../../common/core
    ../../common/options/tlp
    ../../common/options/audio
    ../../common/options/wireless
    ../../common/options/grub-bootloader # for dual boot
    ../../common/options/wayland
    ../../common/options/printing
  ];

  # TODO use this...
  sys-cfg = {
    hostName = "master";
  };

  #FIXME check this:
  systemd.network.wait-online.enable = false;

  networking.hostName = "master";
  networking.firewall.enable = false;

  # only this machine uses nvidia
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  boot.supportedFilesystems = [ "ntfs" ]; # for external hdd

  services = {
    devmon.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
  };

  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_25;
  };

  programs.ssh.startAgent = true;
  programs.nix-ld.enable = true;

  system.stateVersion = "24.05";
}
