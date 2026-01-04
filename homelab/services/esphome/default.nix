{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (config) homelab;
  service = "esphome";
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
    auth = lib.mkOption {
      type = lib.types.str;
      description = "Path to environment file containing USERNAME and PASSWORD";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Wether to open the firewall for the specified port";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 6052;
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      inherit (cfg) openFirewall port;
      package = pkgs.unstable.esphome; # stable had an unsecure python pkg FIXME when this version goes into stable
      usePing = false;
      allowedDevices = [ ];
      address = if cfg.openFirewall then "0.0.0.0" else "localhost";
    };
    systemd.services.${service}.serviceConfig = {
      EnvironmentFile = [ cfg.auth ];
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
