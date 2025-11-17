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
    storageDir = lib.mkOption {
      type = lib.types.str;
      default = "/storage/${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
    };

    envFile = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };
  config = lib.mkIf cfg.enable {

    systemd.tmpfiles.rules = [
      "d ${cfg.configDir}/config 0755 root root -"
      "d ${cfg.storageDir}/media 0755 root root -"
    ];

    systemd.services.frigate-config = {
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

    virtualisation.oci-containers.containers.frigate = {
      image = "ghcr.io/blakeblackshear/frigate:stable";

      # Ports
      ports = [
        "127.0.0.1:8971:8971"
        "8555:8555/tcp" # webrtc
        "8555:8555/udp" # webrtc
      ];

      # Volumes
      volumes = [
        "/etc/localtime:/etc/localtime:ro"
        "${cfg.configDir}/config:/config"
        "${cfg.storageDir}/media:/media/frigate"
      ];

      devices = [
        "/dev/dri/renderD128:/dev/dri/renderD128" # Intel hardware acceleration
      ];

      extraOptions = [
        "--shm-size=512m"
        "--tmpfs=/tmp/cache:size=1000000000"
        "--stop-timeout=30"
      ]
      ++ lib.optionals (cfg.envFile != "") [
        "--env-file=${cfg.envFile}"
      ];

      autoStart = true;
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:8971
      '';
    };
  };
}
