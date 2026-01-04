{
  lib,
  config,
  pkgs,
  ...
}:
{
  programs = {
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;

        format = lib.concatStrings [
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_state"
          "$git_status"
          "$nix_shell"
          "$line_break"
          "$character"
        ];

        hostname = {
          disabled = false;
          format = "[$hostname]($style) ";
          ssh_only = true;
          style = "yellow bold";
          trim_at = ".";
        };
        directory = {
          disabled = false;
          fish_style_pwd_dir_length = 0;
          format = "[$path]($style)[$read_only]($read_only_style) ";
          read_only_style = "red";
          read_only = " !r";
          truncation_length = 10;
          use_logical_path = true;
        };
        git_branch = {
          format = "[$branch]($style)";
          style = "bright-black";
        };
        git_status = {
          format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](purple)($ahead_behind$stashed)]($style) ";
          style = "cyan";
          conflicted = "​";
          untracked = "​";
          modified = "​";
          staged = "​";
          renamed = "​";
          deleted = "​";
          stashed = "≡";
        };

        nix_shell = {
          format = "[nix]($style) ";
          disabled = false;
          style = "blue";
        };
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      dotDir = "${config.home.homeDirectory}/.config/zsh";

      shellAliases = {
        ls = "ls --color";
        nix-shell = "nix-shell --run $SHELL";
      };

      initContent = ''
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        export GOPATH=$HOME/.config/go/golang
        export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
      '';

      plugins = [
        {
          name = pkgs.zsh-autosuggestions.pname;
          inherit (pkgs.zsh-autosuggestions) src;
        }
        {
          name = pkgs.zsh-syntax-highlighting.pname;
          inherit (pkgs.zsh-syntax-highlighting) src;
        }
        {
          name = pkgs.zsh-vi-mode.pname;
          inherit (pkgs.zsh-vi-mode) src;
        }
      ];

      history = {
        ignoreAllDups = true;
        ignoreDups = true;
        ignoreSpace = true;
        share = true;
        path = "$HOME/.local/share/zsh/zsh_history";
      };
    };
  };
}
