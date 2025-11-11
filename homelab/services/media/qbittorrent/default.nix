{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config) homelab;
  service = "qbittorrent";
  cfg = homelab.services.${service};
  inherit (homelab.services.wireguard-netns) namespace;
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
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
    };
    torrentingPort = lib.mkOption {
      type = lib.types.port;
      default = 9999;
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      inherit (homelab) user group;
      inherit (cfg) torrentingPort;
    };

    networking.firewall = lib.mkIf (!homelab.services.wireguard-netns.enable) {
      allowedTCPPorts = [ cfg.torrentingPort ];
      allowedUDPPorts = [ cfg.torrentingPort ];
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };

    systemd = lib.mkIf homelab.services.wireguard-netns.enable {
      services.${service} = {
        bindsTo = [ "netns@${namespace}.service" ];
        requires = [
          "network-online.target"
          "${namespace}.service"
        ];
        serviceConfig.NetworkNamespacePath = [ "/var/run/netns/${namespace}" ];
      };
      sockets."${service}-proxy" = {
        enable = true;
        description = "Socket for proxy to ${service} ui";
        listenStreams = [ "${toString cfg.port}" ];
        wantedBy = [ "sockets.target" ];
      };
      services."${service}-proxy" = {
        enable = true;
        description = "Proxy to ${service} in Network Namespace";
        requires = [
          "${service}.service"
          "${service}-proxy.socket"
        ];
        after = [
          "${service}.service"
          "${service}-proxy.socket"
        ];
        unitConfig = {
          JoinsNamespaceOf = "${service}.service";
        };
        serviceConfig = {
          User = config.services.${service}.user;
          Group = config.services.${service}.group;
          ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${toString cfg.port}";
          PrivateNetwork = "yes";
        };
      };
    };
  };

}
