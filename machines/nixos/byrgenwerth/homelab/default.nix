{ inputs, config, ... }:
let
  sopsFile = "${builtins.toString inputs.nix-secrets}/sops/${config.networking.hostName}.yaml";
  secrets = inputs.nix-secrets;
  hostConf = secrets.networking.subnets.default.hosts.byrgenwerth;

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
    externalIP = hostConf.ip;

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

    cloudflare.dnsCredentialsFile = config.sops.secrets."cloudflare/dnsCredentials".path;

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
        environmentFile = config.sops.secrets."glance/environmentFile".path;
        url = "${config.networking.hostName}-glance.${config.homelab.baseDomain}";
      };

      uptime-kuma.enable = true;
      prometheus-node.enable = true;
    };
  };

  # secrets for the homelab config
  sops.secrets = {
    "cloudflare/dnsCredentials" = mkUserSecret config.users.users.acme.name;
    frigate = mkSecret;
    "glance/environmentFile" = mkSecret;
    navidrome = mkSecret;
  };
}
