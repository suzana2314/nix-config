{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.glance-agent;
in
{
  options.services.glance-agent = {
    enable = lib.mkEnableOption "glance-agent";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.glance-agent;
      description = "The glance-agent package to use";
    };

    environmentFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to a file containing environment variables.
        This file should contain KEY=VALUE pairs, one per line.

        Required variables:
        AUTH_SECRET=your-secret-here

        Optional variables:
        DEBUG=false
        PORT=8080  (overrides port option)
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "glance-agent";
      description = "User to run the service as";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "glance-agent";
      description = "Group to run the service as";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to open the firewall for glance-agent.
        This adds `services.glance-agent.settings.server.port` to `networking.firewall.allowedTCPPorts`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    users.users.${cfg.user} = {
      isSystemUser = true;
      inherit (cfg) group;
      description = "glance-agent service user";
    };

    users.groups.${cfg.group} = { };

    systemd.services.glance-agent = {
      description = "An endpoint written in Go for the glance server stats widget.";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "exec";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${cfg.package}/bin/glance-agent";
        Restart = "always";
        RestartSec = "10s";

        EnvironmentFile = cfg.environmentFile;

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ ];

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        CapabilityBoundingSet = "";
        AmbientCapabilities = "";

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;

        LimitNOFILE = "65536";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

  };
}
