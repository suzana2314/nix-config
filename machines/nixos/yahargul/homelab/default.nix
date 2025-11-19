{ inputs, config, ... }:
let
  sopsFile = "${builtins.toString inputs.nix-secrets}/sops/${config.networking.hostName}.yaml";
in
{
  homelab = {
    enable = true;
    inherit (config.time) timeZone;
    email = inputs.nix-secrets.email.default;
    baseDomain = inputs.nix-secrets.domain;
    enableCaddy = false;

    motd.enable = true;
    notify-ssh = {
      enable = true;
      credentialsFile = config.sops.secrets."telegram/ssh".path;
    };

    services = {
      enable = true;

      ddns-updater = {
        enable = true;
        configFile = config.sops.secrets."cloudflare/ddnsCredentials".path;
        notifications = config.sops.secrets."cloudflare/ddnsNotification".path;
      };

      mosquitto = {
        enable = true;
      };

      homeassistant = {
        enable = true;
        zigbee.enable = false;
        shelly.enable = false;
        cloudflared = {
          tunnelId = inputs.nix-secrets.yahargulTunnelId;
          credentialsFile = config.sops.secrets."cloudflare/tunnelCredentials".path;
        };
      };

      wireguard-server = {
        enable = true;
        port = inputs.nix-secrets.yahargulWgPort;
        privateKeyFile = config.sops.secrets."wireguard/privateKey".path;
        peers = inputs.nix-secrets.yahargulWgPeers;
        networkInterface = "eno1";
      };

      esphome = {
        enable = true;
        openFirewall = true;
        auth = config.sops.secrets.esphome.path;
      };
    };
  };

  # secrets for the homelab config
  sops.secrets = {
    "cloudflare/tunnelCredentials" = {
      inherit sopsFile;
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
    "telegram/ssh" = {
      inherit sopsFile;
      mode = "0400";
    };
    "wireguard/privateKey" = {
      inherit sopsFile;
      mode = "0400";
    };
    esphome = {
      inherit sopsFile;
      owner = config.users.users.esphome.name;
      mode = "0400";
    };
  };

}
