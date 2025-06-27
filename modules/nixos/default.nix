# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # FIXME the lambda that scans paths is not working... 
  # List your module files here
  # my-module = import ./my-module.nix;
  sys-cfg = import ./sys-cfg.nix;
}
