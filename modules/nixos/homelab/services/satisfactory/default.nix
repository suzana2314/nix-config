{
  lib,
  config,
  ...
}:
let
  inherit (config) homelab;
  service = "satisfactory";
  cfg = homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    monitoredServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "${config.virtualisation.oci-containers.backend}-${service}"
      ];
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.configDir}/config 0755 root root -"
    ];
    virtualisation.oci-containers.containers.${service} = {
      image = "docker.io/wolveix/satisfactory-server:latest";
      ports = [
        "7777:7777/tcp"
        "7777:7777/udp"
        "8888:8888/tcp"
      ];
      environment = {
        MAXPLAYERS = "4";
        STEAMBETA = "false";
      };
      volumes = [
        "${cfg.configDir}/config:/config"
      ];
      extraOptions = [
        "--memory=8g"
        "--memory-reservation=4g"
      ];
      autoStart = true;
    };
    networking.firewall = {
      allowedTCPPorts = [
        7777
        8888
      ];
      allowedUDPPorts = [ 7777 ];
    };
  };
}
