{ pkgs, ... }:
{
  programs = {
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
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
          read_only = "";
          truncation_length = 10;
          use_logical_path = true;
        };
        git_branch = {
          symbol = " ";
        };
        nix_shell = {
          format = "with [$symbol]($style) ";
          disabled = false;
          impure_msg = "[impure](bold red)";
          pure_msg = "[pure](bold green)";
          style = "blue bold";
          symbol = "󱄅 ";
        };
        golang.disabled = true;
        rust.disabled = true;
        python.disabled = true;
        java.disabled = true;
        cmake.disabled = true;
        c.disabled = true;
        ocaml.disabled = true;
        battery.disabled = true;
        package.disabled = true;
        gradle.disabled = true;

        cmd_duration = {
          disabled = true;
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
      dotDir = ".config/zsh";

      shellAliases = {
        ls = "ls --color";
        nix-shell = "nix-shell --run $SHELL";
        vpn = "vpn-function";
      };

      initContent = ''
        function vpn-function() {
          if [ "$1" = "up" ]; then 
            nmcli c up vpn-oedon
          elif [ "$1" = "down" ]; then 
            nmcli c down vpn-oedon
          else 
            echo "Usage: vpn up|down"
          fi
        }

        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        export GOPATH=$HOME/.config/go/golang
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
      };
    };
  };
}
