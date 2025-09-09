# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  lenopow = pkgs.callPackage ./lenopow { };
  glance-agent = pkgs.callPackage ./glance-agent { };
}
