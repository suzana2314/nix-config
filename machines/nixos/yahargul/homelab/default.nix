{ inputs, config, ... }:
let
  sopsFile = "${builtins.toString inputs.nix-secrets}/sops/${config.networking.hostName}.yaml";
  secrets = inputs.nix-secrets;

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
    enableCaddy = false;

    motd = {
      enable = true;
      asciiArt = ''
        ██╗   ██╗ █████╗ ██╗  ██╗ █████╗ ██████╗  ██████╗ ██╗   ██╗██╗
        ╚██╗ ██╔╝██╔══██╗██║  ██║██╔══██╗██╔══██╗██╔════╝ ██║   ██║██║
         ╚████╔╝ ███████║███████║███████║██████╔╝██║  ███╗██║   ██║██║
          ╚██╔╝  ██╔══██║██╔══██║██╔══██║██╔══██╗██║   ██║██║   ██║██║
           ██║   ██║  ██║██║  ██║██║  ██║██║  ██║╚██████╔╝╚██████╔╝███████╗
           ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝
      '';
    };

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

      homeassistant = {
        enable = true;
        zigbee.enable = false;
        shelly.enable = false;
        cloudflared.enable = false;
      };

      esphome = {
        enable = true;
        openFirewall = true;
        auth = config.sops.secrets.esphome.path;
      };

      mosquitto = {
        enable = true;
      };

      newt = {
        enable = true;
        environmentFile = config.sops.secrets."newt/environmentFile".path;
      };

      wireguard-server = {
        enable = true;
        port = secrets.yahargulWgPort;
        privateKeyFile = config.sops.secrets."wireguard/privateKey".path;
        peers = secrets.yahargulWgPeers;
        networkInterface = "eno1";
      };
    };
  };

  # secrets for the homelab config
  sops.secrets = {
    "cloudflare/ddnsCredentials" = mkUserSecret config.users.users.ddns-updater.name;
    "cloudflare/ddnsNotification" = mkUserSecret config.users.users.ddns-updater.name;
    "telegram/ssh" = mkSecret;
    "wireguard/privateKey" = mkSecret;
    esphome = mkSecret;
    "newt/environmentFile" = mkSecret;
  };
}
