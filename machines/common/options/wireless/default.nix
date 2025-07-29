{
  networking.networkmanager.enable = true;

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true; # -> display battery information
          FastConnectable = true;
          JustWorksRepairing = "always";
          AutoEnable = true;
        };
      };
    };

    logitech.wireless.enable = true;
    logitech.wireless.enableGraphical = true;
  };
}
