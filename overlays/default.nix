{ inputs, ... }:
{
  # custom packages from pkgs
  additions = final: _prev: import ../pkgs final.pkgs;

  # adds unstable pkgs accessible through pkgs.unstable
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
