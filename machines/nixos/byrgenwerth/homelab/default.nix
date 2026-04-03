{ inputs, config, ... }:
let
  host = config.networking.hostName;
  secrets = inputs.nix-secrets;
  sopsFile = "${builtins.toString secrets}/sops/${host}.yaml";

  mkSecret = {
    inherit sopsFile;
    mode = "0400";
  };
  mkUserSecret = owner: mkSecret // { inherit owner; };
in
{
  homelab = {
    enable = true;
    inherit (config.time) timeZone;
    email = secrets.email.default;
    baseDomain = secrets.domain;

    motd = {
      enable = true;
      asciiArt = ''
        ██████╗ ██╗   ██╗██████╗  ██████╗ ███████╗███╗   ██╗██╗    ██╗███████╗██████╗ ████████╗██╗  ██╗
        ██╔══██╗╚██╗ ██╔╝██╔══██╗██╔════╝ ██╔════╝████╗  ██║██║    ██║██╔════╝██╔══██╗╚══██╔══╝██║  ██║
        ██████╔╝ ╚████╔╝ ██████╔╝██║  ███╗█████╗  ██╔██╗ ██║██║ █╗ ██║█████╗  ██████╔╝   ██║   ███████║
        ██╔══██╗  ╚██╔╝  ██╔══██╗██║   ██║██╔══╝  ██║╚██╗██║██║███╗██║██╔══╝  ██╔══██╗   ██║   ██╔══██║
        ██████╔╝   ██║   ██║  ██║╚██████╔╝███████╗██║ ╚████║╚███╔███╔╝███████╗██║  ██║   ██║   ██║  ██║
        ╚═════╝    ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝
      '';
    };

    reverseProxy = {
      enable = true;
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsCredentialsFile = config.sops.secrets."cloudflare/dnsCredentials".path;
    };

    services = {
      enable = true;

      dns = {
        enable = true;
        url = "dns2.${secrets.domain}";
        dnsMappings = secrets.dnsMappings;
        dnsRewrites = secrets.dnsRewrites;
      };

      media = {
        enable = true;
        navidromeEnvFile = config.sops.secrets.navidrome.path;
        torrentingPort = secrets.torrentingPort;
      };

      immich.enable = true;

      frigate = {
        enable = true;
        envFile = config.sops.secrets.frigate.path;
      };

      glance-agent = {
        enable = true;
        tokenFile = config.sops.secrets."glance/environmentFile".path;
        url = "${config.networking.hostName}-glance.${config.homelab.baseDomain}";
        extraConfig = {
          system.mountpoints."/storage" = {
            hide = false;
            name = "hdd";
          };
        };
      };

      newt = {
        enable = true;
        environmentFile = config.sops.secrets."newt/environmentFile".path;
      };

      prometheus-node.enable = true;
    };
  };

  # secrets for the homelab config
  sops.secrets = {
    "cloudflare/dnsCredentials" = mkUserSecret config.users.users.acme.name;
    frigate = mkSecret;
    "glance/environmentFile" = mkSecret;
    navidrome = mkSecret;
    "newt/environmentFile" = mkSecret;
  };
}
