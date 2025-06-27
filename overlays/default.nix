# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # modifications = final: prev: {
  #   prusa-slicer = final.symlinkJoin {
  #     name = "prusa-slicer";
  #     paths = [ prev.prusa-slicer ];
  #     buildInputs = [ final.makeWrapper ];
  #     postBuild = ''
  #       wrapProgram $out/bin/prusa-slicer \
  #         --set GTK_THEME Adwaita:dark
  #     '';
  #   };
  # };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
  old-packages = final: _prev: {
    old = import inputs.nixpkgs-old {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
}
