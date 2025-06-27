{ config, lib, ... }:
let
  service = "mosquitto";
  conf = config.homelab.services.${service};
  inherit (config) homelab;
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable mosquitto broker";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 1883;
      description = "Port for Mosquitto to listen on locally";
    };
  };
  config = lib.mkIf conf.enable {
    services.${service} = {
      enable = true;
      # Main listener for local connections
      listeners = [
        {
          inherit (conf) port;
          # Only allow connections from localhost
          address = "0.0.0.0";
          acl = [ "pattern readwrite #" ];
          omitPasswordAuth = true;
          settings.allow_anonymous = true;
        }
        {
          port = 8883; # Standard MQTT TLS port
          settings = {
            allow_anonymous = true;
          };
          address = "127.0.0.1";
          acl = [ "pattern readwrite #" ];
          omitPasswordAuth = true;
        }
      ];
    };
  };
}
