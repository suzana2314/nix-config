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
      description = "Enable ${service}";
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
      package =
        lib.warnIf (lib.versionAtLeast pkgs.fosrl-newt.version pkgs.unstable.fosrl-newt.version)
          "${service}: stable now ships ${pkgs.fosrl-newt.version}, drop the unstable override"
          pkgs.unstable.fosrl-newt;
      inherit (cfg) environmentFile;
    };
  };
}
