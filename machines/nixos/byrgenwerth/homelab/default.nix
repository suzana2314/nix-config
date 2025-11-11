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
      ddns-updater = {
        enable = true;
        configFile = config.sops.secrets."cloudflare/ddnsCredentials".path;
        notifications = config.sops.secrets."cloudflare/ddnsNotification".path;
      };

      glance = {
        enable = true;
        apiToken = config.sops.secrets."glance/hemwickApitoken".path;
      };
      immich.enable = true;
      uptime-kuma.enable = true;

      frigate = {
        enable = true;
        envFile = config.sops.secrets.frigate.path;
      };
    };
  };

  # secrets for the homelab config
  sops.secrets = {
    "cloudflare/dnsCredentials" = {
      inherit sopsFile;
      owner = config.users.users.acme.name;
      mode = "0400";
    };
    "cloudflare/ddnsCredentials" = {
      inherit sopsFile;
      owner = config.users.users.ddns-updater.name;
      group = config.users.users.ddns-updater.name;
      mode = "0400";
    };
    "cloudflare/ddnsNotification" = {
      inherit sopsFile;
      owner = config.users.users.ddns-updater.name;
      group = config.users.users.ddns-updater.name;
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
    "glance/hemwickApitoken" = {
      inherit sopsFile;
      mode = "0400";
    };
    navidrome = {
      inherit sopsFile;
      mode = "0400";
    };
  };

}
