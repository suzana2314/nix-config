{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "glance-agent";
  cfg = homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 27973;
    };
    tokenFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to environment file";
    };
    extraConfig = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Additional settings for the agent";
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      inherit (cfg) tokenFile;
      settings = lib.recursiveUpdate {
        server = {
          host = "127.0.0.1";
          port = cfg.port;
        };
        system = {
          hide-mountpoints-by-default = true;
          mountpoints = {
            "/" = {
              hide = false;
              name = "root";
            };
          };
        };
      } cfg.extraConfig;
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
