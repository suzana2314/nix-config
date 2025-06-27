{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "adguardhome";
  cfg = homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      openFirewall = true; # FIXME check this...
    };

    networking.firewall = {
      allowedUDPPorts = [ 53 ]; # open dns port
    };
  };
}
