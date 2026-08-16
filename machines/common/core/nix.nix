{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  sopsFile = "${toString inputs.nix-secrets}/sops/shared.yaml";
in
{
  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      # FIXME: remove when merged into stable
      package = pkgs.unstable.nix;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        flake-registry = "";
        nix-path = config.nix.nixPath;
        warn-dirty = false;
        trusted-users = [
          "root"
          "@wheel"
        ];
        use-xdg-base-directories = true;
      };

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };

      optimise = {
        automatic = true;
        dates = [ "weekly" ];
      };

      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

      extraOptions = ''
        !include ${config.sops.secrets.gh-token.path}
      '';
    };

  sops.secrets.gh-token = {
    inherit sopsFile;
    mode = "0440";
  };
}
