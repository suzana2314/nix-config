{ pkgs, checks, ... }:
{
  default = pkgs.mkShell {
    inherit (checks.pre-commit-check) shellHook;
    buildInputs = checks.pre-commit-check.enabledPackages;

    nativeBuildInputs = builtins.attrValues {
      inherit (pkgs)
        nh
        git
        just
        sops
        age
        ssh-to-age
        pre-commit
        deadnix
        lua-language-server
        nixd
        ;
    };
  };
}
