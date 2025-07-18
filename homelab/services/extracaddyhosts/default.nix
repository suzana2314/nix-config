{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "extraCaddyHosts";
  cfg = homelab.services.${service};

  hostOptions =
    { name, ... }:
    {
      options = {
        enable = lib.mkEnableOption "Enable ${name} caddy host";
        domain = lib.mkOption {
          type = lib.types.str;
          default = "${name}.${homelab.baseDomain}";
          description = "Domain for the ${name} service";
        };
        host = lib.mkOption {
          type = lib.types.str;
          description = "Hostname or IP address where the ${name} service is running";
        };
        port = lib.mkOption {
          type = lib.types.port;
          default = 80;
          description = "Port where the ${name} service is running (defaults to 80)";
        };
        useACMEHost = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = homelab.baseDomain;
          description = "ACME host to use for SSL certificate";
        };
      };
    };
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };

    hosts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule hostOptions);
      default = { };
      description = "Caddy hosts to configure";
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      virtualHosts = lib.mapAttrs' (
        _: hostCfg:
        lib.nameValuePair hostCfg.domain (
          lib.mkIf hostCfg.enable {
            inherit (hostCfg) useACMEHost;
            extraConfig = ''
              reverse_proxy http://${hostCfg.host}:${toString hostCfg.port}
            '';
          }
        )
      ) (lib.filterAttrs (_: hostCfg: hostCfg.enable) cfg.hosts);
    };
  };
}
