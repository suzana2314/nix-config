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
        ];
      }
    ];
    basic_auth =
      mkAuthConfig "prometheus-oedon"
        config.sops.secrets."prometheus/hostsPasswordFile".path;
  }
  {
    job_name = "DNS Primary";
    static_configs = [ { targets = [ (mkHostTarget "dns1") ]; } ];
  }
  {
    job_name = "DNS Secondary";
    static_configs = [ { targets = [ (mkHostTarget "dns2") ]; } ];
  }
]
