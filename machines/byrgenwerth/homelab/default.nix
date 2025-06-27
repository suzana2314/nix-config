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

    services = {
      enable = true;
      mediaStack = {
        enable = true;
        gluetun = {
          enable = true;
          inherit (inputs.nix-secrets) vpnProvider vpnCities;
          vpnCredentialsFile = config.sops.secrets."vpn/credentialsFile".path;
        };
      };
      ddns-updater = {
        enable = true;
        configFile = config.sops.secrets."cloudflare/ddnsCredentials".path;
        notifications = config.sops.secrets."cloudflare/ddnsNotification".path;
      };
      gotify.enable = true;
      glance.enable = true;
      immich.enable = true;
      uptime-kuma.enable = true;
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
  };

}
