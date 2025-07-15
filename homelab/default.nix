{ lib, config, ... }:
let
  conf = config.homelab;
in
{
  options.homelab = {
    enable = lib.mkEnableOption "Homelab service and configuration variables";

    user = lib.mkOption {
      default = "homelab";
      type = lib.types.str;
    };
    group = lib.mkOption {
      default = "homelab";
      type = lib.types.str;
    };

    timeZone = lib.mkOption {
      default = "Europe/Lisbon";
      type = lib.types.str;
    };
    baseDomain = lib.mkOption {
      default = "";
      type = lib.types.str;
    };
    email = lib.mkOption {
      default = "";
      type = lib.types.str;
    };
    cloudflare.dnsCredentialsFile = lib.mkOption {
      type = lib.types.path;
    };
    externalIP = lib.mkOption {
      type = lib.types.str;
      description = "External IP address for services";
    };
  };
  imports = [
    ./services
    ./motd
    ./notify-ssh
  ];
  config = lib.mkIf conf.enable {
    users = {
      groups.${conf.group} = {
        gid = 993;
      };
      users.${conf.user} = {
        uid = 994;
        isSystemUser = true;
        inherit (conf) group;
      };
    };
  };
}
