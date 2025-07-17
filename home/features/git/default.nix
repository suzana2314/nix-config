{ inputs, config, ... }:
let
  sshFolder = "${config.home.homeDirectory}/.ssh";
  signingkey = "${sshFolder}/commit_sign_key.pub";
  allowedSignersFile = "${sshFolder}/allowed_signers";
in
{
  programs.git = {
    enable = true;
    aliases = {
      graph = "log --decorate --oneline --graph";
    };
    userName = "suzana2314";
    userEmail = inputs.nix-secrets.email.github;
    extraConfig = {
      init.defaultBranch = "master";
      user = {
        signByDefault = true;
        inherit signingkey;
      };
      commit.gpgsign = true;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = allowedSignersFile;

      pull = {
        rebase = true;
      };

      core = {
        editor = "vim";
      };
    };
  };
}
