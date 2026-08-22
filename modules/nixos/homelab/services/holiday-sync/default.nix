{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (config) homelab;
  service = "holiday-sync";
  cfg = homelab.services.${service};

  pythonEnv = pkgs.python3.withPackages (
    ps: with ps; [
      holidays
      caldav
      icalendar
    ]
  );

  script = ./holiday-sync.py;
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };

    environmentFile = lib.mkOption {
      type = lib.types.path;
      example = ''
        CALDAV_URL=https://dav.example.com
        CALDAV_USERNAME=micolash
        CALDAV_CALENDAR_PATH=/micolash/pt-holidays/
        CALDAV_PASSWORD=hunter2
      '';
    };

    calendarName = lib.mkOption {
      type = lib.types.str;
      default = "Holidays";
      description = "Display name to use";
    };

    yearsAhead = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "How many years into the future to generate holidays for";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.${service} = {
      description = "Sync pt-PT holidays into a caldav server";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      environment = {
        CALDAV_CALENDAR_NAME = cfg.calendarName;
        YEARS_AHEAD = toString cfg.yearsAhead;
      };

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pythonEnv}/bin/python3 ${script}";
        EnvironmentFile = cfg.environmentFile;
        DynamicUser = true;

        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        SystemCallFilter = [ "@system-service" ];
        SystemCallErrorNumber = "EPERM";
        CapabilityBoundingSet = "";
      };
    };

    systemd.timers.${service} = {
      description = "Timer for ${service}";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "yearly";
        Persistent = true;
      };
    };
  };
}
