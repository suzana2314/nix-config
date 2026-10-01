{ inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
    ./disko.nix
    ./homelab
    ../../common/core
    ../../common/options/systemd-bootloader
    ../../common/options/mdns
    ../../common/options/openssh
    ../../common/users/suz
  ];

  networking = {
    hostName = "yahargul";
    enableIPv6 = false;
    useDHCP = true;
    firewall.enable = true;
    nameservers = [
      "1.1.1.1"
      "9.9.9.9"
    ];
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [
        "1.1.1.1#cloudflare-dns.com"
        "9.9.9.9#dns.quad9.net"
      ];
      FallbackDNS = [
        "1.1.1.1#cloudflare-dns.com"
        "9.9.9.9#dns.quad9.net"
      ];
      Domains = [ "~." ];
      DNSOverTLS = true;
    };
  };

  system.stateVersion = "25.05";
}
