{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (config) homelab;
  service = "frigate";
  cfg = homelab.services.${service};
  frigateConfig = import ./config.nix { inherit inputs config; };
  yamlFormat = pkgs.formats.yaml { };
  configFile = yamlFormat.generate "frigate-config.yaml" frigateConfig;
  webrtcPort = 8555;
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
    port = lib.mkOption {
      type = lib.types.port;
      default = 8971;
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
    storageDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}/data";
    };
    useCfg = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use nix generated configuration file";
    };
    environmentFile = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    detectorPath = lib.mkOption {
      type = lib.types.str;
      description = "Path to the detector device";
    };
  };
  config = lib.mkIf cfg.enable {
    homelab.ports = [
      cfg.port
      webrtcPort
    ];
    systemd.tmpfiles.rules = [
      "d ${cfg.configDir}/config 0755 root root -"
      "d ${cfg.storageDir}/media 0755 root root -"
    ];
    systemd.services.frigate-config = lib.mkIf cfg.useCfg {
      description = "Generate Frigate configuration";
      wantedBy = [ "multi-user.target" ];
      before = [ "${config.virtualisation.oci-containers.backend}-frigate.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.coreutils}/bin/cp ${configFile} ${cfg.configDir}/config/config.yaml";
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${cfg.configDir}/config";
      };
    };
    virtualisation.oci-containers.containers.${service} = {
      image = "ghcr.io/blakeblackshear/frigate:stable";
      ports = [
        "${if homelab.services.reverseProxy.enable then "127.0.0.1:" else ""}${toString cfg.port}:8971"
        "${toString webrtcPort}:${toString webrtcPort}/tcp" # webrtc
        "${toString webrtcPort}:${toString webrtcPort}/udp" # webrtc
      ];
      volumes = [
        "/etc/localtime:/etc/localtime:ro"
        "${cfg.configDir}/config:/config"
        "${cfg.storageDir}/media:/media/frigate"
      ];
      extraOptions = [
        "--shm-size=512m"
        "--tmpfs=/tmp/cache:size=1000000000"
        "--stop-timeout=30"
        "--device=${cfg.detectorPath}"
      ]
      ++ lib.optionals (cfg.environmentFile != "") [
        "--env-file=${cfg.environmentFile}"
      ];
      autoStart = true;
      labels."io.containers.autoupdate" = "registry";
    };
    networking.firewall = lib.mkMerge [
      {
        allowedTCPPorts = [ webrtcPort ];
        allowedUDPPorts = [ webrtcPort ];
      }
      (lib.mkIf (!homelab.services.reverseProxy.enable) {
        allowedTCPPorts = [ cfg.port ];
      })
    ];
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
