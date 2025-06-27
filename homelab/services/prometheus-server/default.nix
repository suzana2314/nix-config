{ lib, config, ... }:
let
  inherit (config) homelab;
  service = "prometheus";
  cfg = homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
    };
    scrapeConfigs = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      description = "The jobs to scrape";
    };
  };

  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      globalConfig.scrape_interval = "30s";
      inherit (cfg) scrapeConfigs;
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString config.services.prometheus.port}
      '';
    };
  };
}
