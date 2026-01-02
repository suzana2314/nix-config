{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (config) homelab;
  service = "dns";
  cfg = homelab.services.${service};
  networkCfg = inputs.nix-secrets.networking;
  ip = networkCfg.${config.networking.hostName}.ip;
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "dns.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.str;
      default = "8341";
    };
    dnsMappings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        "example.com" = "192.168.0.1";
      };
    };
    dnsRewrites = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        "example.com" = "example-rewrite.com";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.blocky = {
      enable = true;
      settings = {
        ports = {
          dns = [ "${ip}:53" ];
          http = cfg.port;
        };
        connectIPVersion = "v4";
        upstreams.groups.default = [ "127.0.0.2:5353" ];

        blocking = {
          denylists = {
            "pro" = [ "https://codeberg.org/hagezi/mirror2/raw/branch/main/dns-blocklists/wildcard/pro.txt" ];
            "tif" = [ "https://codeberg.org/hagezi/mirror2/raw/branch/main/dns-blocklists/wildcard/tif.txt" ];
          };
          clientGroupsBlock.default = [
            "pro"
            "tif"
          ];
          loading = {
            downloads = {
              attempts = 8;
              cooldown = "2s";
            };
            strategy = "fast";
            concurrency = 1;
          };
        };

        customDNS = lib.mkIf (cfg.dnsMappings != { }) {
          customTTL = "1h";
          mapping = cfg.dnsMappings;
          rewrite = cfg.dnsRewrites;
        };

        caching = {
          prefetching = true;
          minTime = "1m";
        };

        queryLog = {
          type = "csv";
          logRetentionDays = 3;
          target = "/var/log/blocky";
        };

        prometheus = {
          enable = true;
          path = "/metrics";
        };
      };
    };

    services.unbound = {
      enable = true;
      resolveLocalQueries = false;
      settings = {
        server = {
          interface = [ "127.0.0.2" ];
          port = 5353;
          access-control = [ "127.0.0.0/8 allow" ];
          do-ip4 = true;
          do-ip6 = false;

          harden-glue = true;
          harden-dnssec-stripped = true;
          use-caps-for-id = false;
          prefetch = true;
          edns-buffer-size = 1232;

          hide-identity = true;
          hide-version = true;

          root-hints = "${pkgs.dns-root-data}/root.hints";

          unwanted-reply-threshold = 10000;
          private-address = [
            "10.0.0.0/8"
            "172.16.0.0/12"
            "192.168.0.0/16"
            "169.254.0.0/16"
            "fd00::/8"
            "fe80::/10"
          ];
        };
      };
    };

    networking.firewall = {
      allowedUDPPorts = [ 53 ];
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
