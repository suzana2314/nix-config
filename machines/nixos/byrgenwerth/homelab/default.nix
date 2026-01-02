{ inputs, config, ... }:
let
  sopsFile = "${builtins.toString inputs.nix-secrets}/sops/${config.networking.hostName}.yaml";
  networkConf = inputs.nix-secrets.networking;
  hostConf = networkConf.subnets.default.hosts.byrgenwerth;
in
{
  homelab = {
    enable = true;
    inherit (config.time) timeZone;
    email = inputs.nix-secrets.email.default;
    baseDomain = inputs.nix-secrets.domain;
    cloudflare.dnsCredentialsFile = config.sops.secrets."cloudflare/dnsCredentials".path;
    externalIP = hostConf.ip;

    motd.enable = true;

    notify-ssh = {
      enable = true;
      credentialsFile = config.sops.secrets."telegram/ssh".path;
    };

    services = {
      enable = true;

      dns = {
        enable = true;
        url = "dns2.${inputs.nix-secrets.domain}";
        dnsMappings = inputs.nix-secrets.dnsMappings;
        dnsRewrites = inputs.nix-secrets.dnsRewrites;
      };

      media = {
        enable = true;
        navidromeEnvFile = config.sops.secrets.navidrome.path;
        torrentingPort = inputs.nix-secrets.torrentingPort;
      };

      wireguard-netns = {
        enable = false;
        configFile = config.sops.secrets."vpn/credentialsFile".path;
        privateIP = inputs.nix-secrets.vpnPrivateIP;
        dnsIP = inputs.nix-secrets.vpnDnsIP;
      };

      glance-agent = {
        enable = true;
        environmentFile = config.sops.secrets."glance/environmentFile".path;
        url = "${config.networking.hostName}-glance.${config.homelab.baseDomain}";
      };

      immich.enable = true;

      uptime-kuma.enable = true;

      frigate = {
        enable = true;
        envFile = config.sops.secrets.frigate.path;
      };

      prometheus-node.enable = true;
    };
  };

  # secrets for the homelab config
  sops.secrets = {
    "cloudflare/dnsCredentials" = {
      inherit sopsFile;
      owner = config.users.users.acme.name;
      mode = "0400";
    };
    "vpn/credentialsFile" = {
      inherit sopsFile;
    };
    frigate = {
      inherit sopsFile;
      mode = "0400";
    };
    "telegram/ssh" = {
      inherit sopsFile;
      mode = "0400";
    };
    "glance/environmentFile" = {
      inherit sopsFile;
      mode = "0400";
    };
    navidrome = {
      inherit sopsFile;
      mode = "0400";
    };
  };

}
