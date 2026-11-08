{ inputs, config, ... }:
let
  host = config.networking.hostName;
  secrets = inputs.nix-secrets;
  sopsFile = "${toString secrets}/sops/${host}.yaml";

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

    motd.enable = true;

    services = {
      enable = true;

      reverseProxy = {
        enable = true;
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        dnsCredentialsFile = config.sops.secrets."cloudflare/dnsCredentials".path;
        metrics = {
          enable = true;
          environmentFile = config.sops.secrets."caddy/environmentFile".path;
        };
      };

      node-exporter = {
        enable = true;
        environmentFile = config.sops.secrets."node-exporter/environmentFile".path;
      };

      klipper = {
        enable = true;
        settings = import ./printer/klipper.nix;
      };

      moonraker.enable = true;
    };
  };

  sops.secrets = {
    "cloudflare/dnsCredentials" = mkUserSecret config.users.users.acme.name;
    "node-exporter/environmentFile" = mkSecret;
    "caddy/environmentFile" = mkSecret;
  };
}
