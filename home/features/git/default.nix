{ inputs, config, ... }:
let
  sshFolder = "${config.home.homeDirectory}/.ssh";
  signingkey = "${sshFolder}/commit_sign_key.pub";
  allowedSignersFile = "${sshFolder}/allowed_signers";
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
        email = inputs.nix-secrets.email.github;
        signByDefault = true;
      };

      commit.gpgsign = true;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = allowedSignersFile;

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
