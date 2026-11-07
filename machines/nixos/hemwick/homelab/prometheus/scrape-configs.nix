{ config }:
let
  mkHostTarget = host: "${host}.${config.homelab.baseDomain}";
  mkAuthConfig = user: passwordFile: {
    username = user;
    password_file = passwordFile;
  };
in
[
  {
    job_name = "hosts";
    static_configs = [
      {
        targets = map mkHostTarget [
          "hemwick"
          "byrgenwerth"
          "kos"
          "mensis"
          "yahargul"
        ];
      }
    ];
    basic_auth = mkAuthConfig "prometheus-oedon" config.sops.secrets."prometheus/nodePasswordFile".path;
  }
  {
    job_name = "caddy";
    static_configs = [
      {
        targets = map mkHostTarget [
          "hemwick"
          "byrgenwerth"
          "mensis"
        ];
      }
    ];
    metrics_path = "/caddy/metrics";
    basic_auth =
      mkAuthConfig "prometheus-oedon"
        config.sops.secrets."prometheus/caddyPasswordFile".path;
  }
  {
    job_name = "DNS Primary";
    static_configs = [ { targets = [ (mkHostTarget "dns1") ]; } ];
  }
  {
    job_name = "DNS Secondary";
    static_configs = [ { targets = [ (mkHostTarget "dns2") ]; } ];
  }
  {
    job_name = "Prometheus";
    static_configs = [ { targets = [ "localhost:9090" ]; } ];
  }
  {
    job_name = "Storage Box";
    static_configs = [ { targets = [ (mkHostTarget "storagebox-metrics") ]; } ];
    basic_auth =
      mkAuthConfig "prometheus-oedon"
        config.sops.secrets."prometheus/storageboxPasswordFile".path;
  }
]
