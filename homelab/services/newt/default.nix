{
  config,
  lib,
  pkgs,
  ...
}:
let
  service = "newt";
  cfg = config.homelab.services.${service};
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
    environmentFile = lib.mkOption {
      type = lib.types.path;
      example = ''
        NEWT_ID=2ix2t8xk22ubpfy
        NEWT_SECRET=nnisrfsdfc7prqsp9ewo1dvtvci50j5uiqotez00dgap0ii2
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      inherit (cfg) environmentFile;
      package = pkgs.unstable.fosrl-newt;
    };
  };
}
