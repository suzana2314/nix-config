{ inputs, config, ... }:
let
  inherit (config.home) username;
  sopsFile = (toString inputs.nix-secrets) + "/sops";
in
{
  sops.secrets = {
    "yubico/u2f_keys" = {
      sopsFile = "${sopsFile}/${username}.yaml";
      path = "${config.xdg.configHome}/Yubico/u2f_keys";
    };
  };
}
