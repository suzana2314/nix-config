{
  services.printing = {
    enable = true;
  };

  # This is for mDNS discovery to find the printer in the network
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

}
