{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.glance-agent;
  settingsFormat = pkgs.formats.yaml { };
  settingsFile = settingsFormat.generate "agent.yml" cfg.settings;
  mergedSettingsFile = "/run/glance-agent/agent.yml";
in
{
  options.services.glance-agent = {
    enable = lib.mkEnableOption "glance-agent";
    package = lib.mkPackageOption pkgs "glance-agent" { };

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      description = ''
        Configuration for glance-agent, written to agent.yml.
        See https://github.com/glanceapp/agent for available options.
      '';
      example = lib.literalExpression ''
        {
          server.port = 27973;
          system.mountpoints."/boot".hide = true;
        }
      '';
    };

    tokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a file containing the authentication token to set as
        `server.token`. If set, the token will not be stored in the Nix store.
      '';
      example = "/run/secrets/glance-agent-token";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the configured port in the firewall.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.glance-agent = {
      description = "Glance Agent Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStartPre =
          # "+" runs as root so it can read secret files regardless of permissions
          "+"
          + pkgs.writeShellScript "glance-agent-start-pre" ''
            install -m 600 -o "$USER" ${settingsFile} ${mergedSettingsFile}
            ${lib.optionalString (cfg.tokenFile != null) ''
              ${pkgs.gnused}/bin/sed -i \
                "s/token:.*/token: $(cat ${lib.escapeShellArg cfg.tokenFile})/" \
                ${mergedSettingsFile}
            ''}
          '';

        ExecStart = "${lib.getExe cfg.package} --config ${mergedSettingsFile}";

        Restart = "always";
        StartLimitIntervalSec = "5min";
        StartLimitBurst = 3;
        DynamicUser = true;
        RuntimeDirectory = "glance-agent";
        RuntimeDirectoryMode = "0700";

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateUsers = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      (cfg.settings.server.port or 27973)
    ];
  };
}
