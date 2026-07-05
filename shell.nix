{ pkgs, ... }:
{
  default = pkgs.mkShell {
    packages = with pkgs; [
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
      prek
      ty
    ];

    shellHook = ''
      # to install git hooks
      ${pkgs.prek}/bin/prek install
    '';
  };
}
