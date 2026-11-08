{
  config,
  lib,
  ...
}:
let
  inherit (config) homelab;
  service = "moonraker";
  cfg = homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 7125;
    };
  };

  config = lib.mkIf cfg.enable {
    homelab.ports = [ cfg.port ];
    services.${service} = {
      enable = true;
      inherit (cfg) port;
      address = "0.0.0.0";

      settings = {
        server = {
          max_upload_size = 1024;
        };
        file_manager = {
          enable_object_processing = true;
        };
        authorization = {
          trusted_clients = [
            "127.0.0.1"
            "::1"
            "10.0.0.0/8"
            "192.168.0.0/16"
            "172.16.0.0/12"
            "fe80::/10"
          ];

          cors_domains = [
            "http://*.lan"
            "http://*.local"
            "https://*.local"
            "https://*.lan"
            "https://my.mainsail.xyz"
            "http://my.mainsail.xyz"
            "https://app.fluidd.xyz"
            "http://app.fluidd.xyz"
          ];
        };

        octoprint_compat = { };
        history = { };
        announcements = {
          subscriptions = [ "mainsail" ];
        };
      };
    };
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
