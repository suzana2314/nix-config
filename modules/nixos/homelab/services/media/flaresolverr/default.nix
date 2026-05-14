{ config, lib, ... }:
let
  inherit (config) homelab;
  service = "flaresolverr";
  cfg = homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
    };
  };
}
