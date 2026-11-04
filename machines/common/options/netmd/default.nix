{ pkgs, ... }:

{
  # this is for sony devices only
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", MODE="0666", TAG+="uaccess"
  '';

  environment.systemPackages = with pkgs; [
    electronwmd
  ];

}
