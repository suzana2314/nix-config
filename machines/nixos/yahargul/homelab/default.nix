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
    cloudflare.dnsCredentialsFile = config.sops.secrets."cloudflare/dnsCredentials".path;

    motd.enable = true;
    notify-ssh = {
      enable = true;
      credentialsFile = config.sops.secrets."telegram/ssh".path;
    };

    services = {
      enable = true;
      adguardhome.enable = true;
      mosquitto = {
        enable = true;
      };
      homeassistant = {
        enable = true;
        cloudflared = {
          inherit (inputs.nix-secrets) tunnelId;
          credentialsFile = config.sops.secrets."cloudflare/tunnelCredentials".path;
        };
      };
    };
  };

  # secrets for the homelab config
  sops.secrets = {
    "cloudflare/tunnelCredentials" = {
      inherit sopsFile;
    };
    "cloudflare/dnsCredentials" = {
      inherit sopsFile;
      owner = config.users.users.acme.name;
      mode = "0400";
    };
    "telegram/ssh" = {
      inherit sopsFile;
      mode = "0400";
    };
  };

}
