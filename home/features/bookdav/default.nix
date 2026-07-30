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
        rename_epubs = true;
        keep_converted = false;
        dir = "${config.xdg.userDirs.documents}/epubs";
      };
    };
  };

  sops.secrets.bookdav.sopsFile = "${sopsFile}/${username}.yaml";
}
