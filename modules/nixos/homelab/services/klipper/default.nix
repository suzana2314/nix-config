{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config) homelab;
  service = "klipper";
  cfg = homelab.services.${service};
  format = pkgs.formats.ini {
    listToValue =
      l:
      if builtins.length l == 1 then
        lib.generators.mkValueStringDefault { } (lib.head l)
      else
        lib.concatMapStrings (s: "\n  ${lib.generators.mkValueStringDefault { } s}") l;
    mkKeyValue = lib.generators.mkKeyValueDefault { } ":";
  };
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "mainsail.${homelab.baseDomain}";
    };
    moonrakerPort = lib.mkOption {
      type = lib.types.port;
      default = 7125;
    };
    klipperSettings = lib.mkOption {
      type = format.type;
      default = { };
      description = "Klipper config";
    };
    monitoredServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "klipper"
        "moonraker"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    homelab.ports = [ cfg.moonrakerPort ];
    services.klipper = {
      enable = true;
      user = "klipper";
      group = "klipper";
      logFile = "/var/lib/klipper/klipper.log";
      settings = cfg.klipperSettings;
      mutableConfig = false;
    };
    services.moonraker = {
      enable = true;
      port = cfg.moonrakerPort;
      address = "127.0.0.1";

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
            "https://${cfg.url}"
            "http://*.lan"
            "http://*.local"
            "https://*.local"
            "https://*.lan"
          ];
        };

        octoprint_compat = { };
        history = { };
        announcements = {
          subscriptions = [ "mainsail" ];
        };

        # should this be configured here?
        "power light_strip" = {
          type = "gpio";
          pin = "gpio17";
          off_when_shutdown = true;
          initial_state = "on";
        };
      };
    };

    users.groups.gpio = { };
    users.groups.klipper = { };
    users.users.klipper = {
      isSystemUser = true;
      group = "klipper";
    };
    users.users.moonraker.extraGroups = [
      "klipper"
      "gpio"
    ];

    services.udev.extraRules = ''
      SUBSYSTEM=="gpio", KERNEL=="gpiochip*", GROUP="gpio", MODE="0660"
    '';

    services.caddy.virtualHosts.${cfg.url} = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        @moonraker path /websocket /printer/* /api/* /access/* /machine/* /server/*
        handle @moonraker {
          reverse_proxy 127.0.0.1:${toString cfg.moonrakerPort}
        }

        handle {
          root * ${pkgs.mainsail}/share/mainsail
          header /index.html Cache-Control "no-store, no-cache, must-revalidate"
          try_files {path} /index.html
          file_server
        }
      '';
    };
  };
}
