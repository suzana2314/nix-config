{ pkgs, checks, ... }:
{
  default = pkgs.mkShell {
    inherit (checks.pre-commit-check) shellHook;
    buildInputs = checks.pre-commit-check.enabledPackages;

    nativeBuildInputs = builtins.attrValues {
      inherit (pkgs)
        age
        deadnix
        git
        just
        lua-language-server
        nh
        nil
        nix-update
        nixd
        pre-commit
        python3
        ruff
        sbctl
        sops
        ssh-to-age
        ty
        ;
    };
  };
}
