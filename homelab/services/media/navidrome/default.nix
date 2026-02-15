{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config) homelab;
  service = "navidrome";
  cfg = homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 4533;
    };
    mediaDir = lib.mkOption {
      type = lib.types.str;
    };
    environmentFile = lib.mkOption {
      type = lib.types.path;
      example = lib.literalExpression ''
        pkgs.writeText "navidrome-env" '''
          ND_LASTFM_APIKEY=abcabc
          ND_LASTFM_SECRET=abcabc
        '''
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      package = pkgs.navidrome;
      inherit (homelab) user group;
      inherit (cfg) environmentFile;
      settings = {
        MusicFolder = "${cfg.mediaDir}/media/music";
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
