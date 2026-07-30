{ inputs, config, ... }:
let
  inherit (config.home) username;
  sopsFile = (toString inputs.nix-secrets) + "/sops";
  baseDomain = inputs.nix-secrets.domain;
in
{
  imports = [
    inputs.bookdav.homeManagerModules.default
  ];

  programs.bookdav = {
    enable = true;
    settings = {
      server = {
        url = "https://webdav.${baseDomain}";
        username = "${username}-kobo";
        passwordFile = config.sops.secrets.bookdav.path;
      };
      epub = {
        kepubify = false;
        rename = true;
        dir = "${config.xdg.userDirs.documents}/epubs";
      };
    };
  };

  sops.secrets.bookdav.sopsFile = "${sopsFile}/${username}.yaml";
}
