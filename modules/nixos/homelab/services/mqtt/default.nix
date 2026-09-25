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
    users = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            hashedPasswordFile = lib.mkOption {
              type = lib.types.path;
            };
            acl = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              example = [ "readwrite frigate/#" ];
              description = "ACL rules for this user.";
            };
          };
        }
      );
      default = { };
      description = "mqtt users to provision on this broker";
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      listeners = [
        {
          inherit (cfg) port;
          address = "0.0.0.0";
          users = cfg.users;
        }
      ];
    };
    networking.firewall = lib.mkIf homelab.services.${service}.enable {
      allowedTCPPorts = [ cfg.port ];
    };
  };
}
