{ config, lib, ... }:
let
  service = "mosquitto";
  cfg = config.homelab.services.${service};
  inherit (config) homelab;
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 1883;
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      listeners = [
        # FIXME: don't forget the protection :)
        {
          inherit (cfg) port;
          address = "0.0.0.0";
          acl = [ "pattern readwrite #" ];
          omitPasswordAuth = true;
          settings.allow_anonymous = true;
        }
      ];
    };
    networking.firewall = lib.mkIf homelab.services.mosquitto.enable {
      allowedTCPPorts = [ cfg.port ];
    };
  };
}
