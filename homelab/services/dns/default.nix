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
  host = config.networking.hostName;
  ip = inputs.nix-secrets.networking.hosts.${host}.ip;
  unboundAddress = "127.0.0.2";
  unboundPort = 5353;
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
        upstreams.groups.default = [ "${unboundAddress}:${toString unboundPort}" ];
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
          interface = [ "${unboundAddress}" ];
          port = unboundPort;
          access-control = [ "127.0.0.0/8 allow" ];
          do-ip4 = true;
          do-ip6 = false;
          do-udp = true;
          do-tcp = true;
          harden-glue = true;
          harden-dnssec-stripped = true;
          use-caps-for-id = false;
          prefetch = true;
          edns-buffer-size = 1232;
          hide-identity = true;
          hide-version = true;
          root-hints = "${pkgs.dns-root-data}/root.hints";
          unwanted-reply-threshold = 10000;
          so-rcvbuf = "1m";
          private-address = [
            "10.0.0.0/8"
            "172.16.0.0/12"
            "192.168.0.0/16"
            "169.254.0.0/16"
            "fd00::/8"
            "fe80::/10"
            "192.0.2.0/24"
            "198.51.100.0/24"
            "203.0.113.0/24"
            "255.255.255.255/32"
            "2001:db8::/32"
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
