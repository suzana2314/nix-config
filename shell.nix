{ pkgs, ... }:
{
  default = pkgs.mkShell {
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
