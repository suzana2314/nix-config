{
  inputs,
  config,
  osConfig,
  ...
}:
let
  inherit (config.home) username;
  inherit (osConfig.networking) hostName;
  sopsFile = (toString inputs.nix-secrets) + "/sops/${username}.yaml";
in
{
  sops.secrets = {
    "yubico/${hostName}/u2f_keys" = {
      sopsFile = sopsFile;
      path = "${config.xdg.configHome}/Yubico/u2f_keys";
    };
  };
}
