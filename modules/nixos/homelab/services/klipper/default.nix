{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config) homelab;
  service = "klipper";
  cfg = homelab.services.${service};
  format = pkgs.formats.ini {
    listToValue =
      l:
      if builtins.length l == 1 then
        lib.generators.mkValueStringDefault { } (lib.head l)
      else
        lib.concatMapStrings (s: "\n  ${lib.generators.mkValueStringDefault { } s}") l;
    mkKeyValue = lib.generators.mkKeyValueDefault { } ":";
  };
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    settings = lib.mkOption {
      type = lib.types.nullOr format.type;
      description = "Klipper config";
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      inherit (cfg) settings;
      enable = true;
      logFile = "/var/lib/klipper/klipper.log";
      mutableConfig = false;
    };
  };
}
