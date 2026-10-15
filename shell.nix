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
      opentofu
      tofu-ls
    ];

    shellHook = ''
      # to install git hooks
      ${pkgs.prek}/bin/prek install

      export VIMRUNTIME="${pkgs.neovim-unwrapped}/share/nvim/runtime"
      export CONFIG_LOCATION=$HOME/.config/nix/nix-config
      export SECRETS_LOCATION=$HOME/.config/nix/nix-secrets
    '';
  };
}
