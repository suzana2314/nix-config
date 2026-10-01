{
  lib,
  config,
  options,
  ...
}:
let
  cfg = config.homelab;
  # all credit for this function goes to Lorenz Bischof
  # https://lorenzbischof.ch/posts/detect-port-conflicts-in-nixos-services/
  # https://discourse.nixos.org/t/detect-port-conflicts-in-nixos-services/61589
  duplicatePorts = lib.pipe options.homelab.ports.definitionsWithLocations [
    (lib.concatMap (
      entry:
      map (port: {
        file = entry.file;
        port = port;
      }) entry.value
    ))
    (lib.groupBy (entry: toString entry.port))
    (lib.filterAttrs (port: entries: builtins.length entries > 1))
    (lib.mapAttrsToList (
      port: entries:
      "Duplicate port ${port} found in:\n" + lib.concatMapStrings (entry: " - ${entry.file}\n") entries
    ))
    (lib.concatStrings)
  ];
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
    ports = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [ ];
      description = "List of allocated port numbers";
    };
  };
  imports = [
    ./services
    ./motd
  ];
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = duplicatePorts == "";
        message = duplicatePorts;
      }
    ];
    users = {
      groups.${cfg.group} = {
        gid = 993;
      };
      users.${cfg.user} = {
        uid = 994;
        isSystemUser = true;
        inherit (cfg) group;
      };
    };
  };
}
