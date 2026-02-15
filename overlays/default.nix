# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };

  navidrome = final: prev: {
    navidrome = final.callPackage (prev.fetchurl {
      url = "https://raw.githubusercontent.com/cimm/nixpkgs/71aa374ad541b41e6fccd543c67b6952d2ccafca/pkgs/by-name/na/navidrome/package.nix";
      sha256 = "16mfj85w8d7vzc9pgcgjn7a71z7jywqpdn8igk9zp0hw9dvm9rmq";
    }) { };
  };
}
