{ lib, config }:
let
  args = { inherit lib config; };
in
lib.foldl' lib.recursiveUpdate { } [
  (import ./hardware.nix)
  (import ./core.nix args)
  (import ./kamp.nix args)
  (import ./mainsail.nix args)
  (import ./macros.nix args)
]
