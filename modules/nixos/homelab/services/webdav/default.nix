{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "webdav";
  cfg = homelab.services.${service};

  userDir = u: "${cfg.configDir}/${u.dirName}";
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}/collections";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8904;
    };
    users = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            username = lib.mkOption { type = lib.types.str; };
            password = lib.mkOption { type = lib.types.str; };
            dirName = lib.mkOption { type = lib.types.str; };
            permissions = lib.mkOption {
              type = lib.types.str;
              default = "CRUD";
            };
          };
        }
      );
      default = [ ];
      description = "WebDAV users";

    };
    environmentFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to environment file containing USERNAME and PASSWORD";
      example = ''
        USERNAME=john_doe
        PASSWORD=hunter2
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.tmpfiles.rules = [
      "d ${cfg.configDir} 0700 ${service} ${service} -"
    ]
    ++ map (u: "d ${userDir u} 0700 ${service} ${service} -") cfg.users;

    homelab.ports = [ cfg.port ];
    services.${service} = {
      enable = true;
      environmentFile = cfg.environmentFile;
      settings = {
        address = "127.0.0.1";
        port = cfg.port;
        behindProxy = true;
        directory = cfg.configDir;
        users = map (u: {
          inherit (u) username password permissions;
          directory = userDir u;
        }) cfg.users;
      };
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
