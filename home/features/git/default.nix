{ inputs, config, ... }:
let
  signingkey = "2F98DAB0D65786E9";
in
{
  programs.git = {
    enable = true;
    settings = {
      alias = {
        graph = "log --decorate --oneline --graph";
      };
      user = {
        inherit signingkey;
        name = "suzana2314";
        email = inputs.nix-secrets.email.git;
        signByDefault = true;
      };

      commit.gpgsign = true;
      gpg.program = "${config.programs.gpg.package}/bin/gpg2";

      init.defaultBranch = "master";
      pull = {
        rebase = true;
      };

      core = {
        editor = "vim";
      };
    };
  };
}
