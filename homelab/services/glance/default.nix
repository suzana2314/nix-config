{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (config) homelab;
  service = "glance";
  cfg = homelab.services.${service};
  networkCfg = inputs.nix-secrets.networking;
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    assetsPath = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/glance/assets";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 5678;
    };
    apiToken = lib.mkOption {
      type = lib.types.path;
      description = "The path to the apiToken of the remote machine";
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      package = pkgs.unstable.glance;
      settings = import ./config.nix { inherit config cfg networkCfg; };
    };

    systemd.services.${service}.preStart = ''
      mkdir -p ${cfg.assetsPath}
    '';

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
