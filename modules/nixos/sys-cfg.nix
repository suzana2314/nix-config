{ config, lib, ... }:
{
  options.sys-cfg = {
    username = lib.mkOption {
      type = lib.types.str;
      description = "The username of the system";
    };

    hostName = lib.mkOption {
      type = lib.types.str;
      description = "The hostname of the system";
    };

    networking = lib.mkOption {
      default = { };
      type = lib.types.attrsOf lib.types.anything;
      description = "An attribute set of networking information";
    };

    home = lib.mkOption {
      type = lib.types.str;
      description = "The home dir of the user";
      default =
        let
          user = config.sys-cfg.username;
        in
        "/home/${user}";
    };
  };
}
