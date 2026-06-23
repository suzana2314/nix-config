{ inputs, config, ... }:
let
  sopsFile = "${toString inputs.nix-secrets}/sops/shared.yaml";
  ageKeyFolder = "/home/suz/.config/sops/age";
  owner = config.users.users.suz.name;
  group = config.users.users.suz.group;
in
{
  sops.secrets = {
    "suz-age" = {
      inherit sopsFile owner group;
      path = ageKeyFolder + "/keys.txt";
    };
  };

  system.activationScripts.sopsSetAgeKeyOwnership = ''
    mkdir -p ${ageKeyFolder} || true
    chown -R ${owner}:${group} /home/suz/.config
  '';
}
