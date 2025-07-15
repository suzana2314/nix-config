{ config, lib, pkgs, ... }:
{
  options = {
    nixvim-config.plugins.lspconfig.enable = lib.mkEnableOption "enables lsp module";
  };

  config = lib.mkIf config.nixvim-config.plugins.lspconfig.enable {
    programs.nixvim = {
      plugins = {
        lsp = {
          enable = true;
          inlayHints = true;
          servers = {
            clangd = {
              enable = true;
              package = pkgs.unstable.clang-tools;
              extraOptions = {
                capabilities = {
                  offsetEncoding = [ "utf-16" ];
                };
                init_options = {
                  usePlaceholders = true;
                  completeUnimported = true;
                  clangdFileStatus = true;
                };
              };
              cmd = [
                "clangd"
                "--background-index"
                "--clang-tidy"
                "--header-insertion=iwyu"
                "--completion-style=detailed"
                "--function-arg-placeholders"
                "--fallback-style=llvm"
                "--enable-config"
              ];
            };

            # OCaml
            ocamllsp = {
              enable = false;
              package = pkgs.ocaml-ng.ocamlPackages_4_14.ocaml-lsp;
            };

            # python
            pyright = {
              enable = true;
            };

            # Go
            gopls = {
              enable = true;
              package = null; # default = pkgs.gopls
            };

            rust_analyzer = {
              enable = true;
              package = null;
              installCargo = false;
              installRustc = false;
              installRustfmt = false;

              settings.settings = {
                diagnostics = {
                  enable = true;
                  styleLints.enable = true;
                };
                files = {
                  excludeDirs = [
                    ".direnv"
                    "rust/.direnv"
                  ];
                };

                inlayHints = {
                  bindingModeHints.enable = true;
                  closureStyle = "rust_analyzer";
                  closureReturnTypeHints.enable = "always";
                  discriminantHints.enable = "always";
                  expressionAdjustmentHints.enable = "always";
                  implicitDrops.enable = true;
                  lifetimeElisionHints.enable = "always";
                  rangeExclusiveHints.enable = true;
                };

                procMacro = {
                  enable = true;
                };
              };
            };

            # nix
            nixd = {
              enable = true;
              settings = # TODO change these paths to something more universal (use self, and hostname)
                let
                  nixos = "(builtins.getFlake \"/home/suz/.nixos/\").nixosConfigurations.master.options";
                  nixpkgs = "import (builtins.getFlhome-managerake \"/home/suz/.nixos/\").inputs.nixpkgs { }";
                  home-manager = nixos + ".home-manager.users.type.getSubOptions []";
                in
                {
                  options = {
                    nixos.expr = nixos;
                    nixpkgs.expr = nixpkgs;
                    home-manager.expr = home-manager;
                  };
                };
            };
          };
          keymaps = {
            silent = true;
            lspBuf = {
              gd = {
                action = "definition";
                desc = "Goto definition";
              };
              gr = {
                action = "references";
                desc = "Goto references";
              };
              gD = {
                action = "declaration";
                desc = "Goto declaration";
              };
              gp = {
                action = "implementation";
                desc = "Goto implementation";
              };
              K = {
                action = "hover";
                desc = "Hover";
              };
              "<leader>ca" = {
                action = "code_action";
                desc = "Code action";
              };
              "<leader>cr" = {
                action = "rename";
                desc = "Rename";
              };
              "<leader>sh" = {
                action = "signature_help";
                desc = "Signature help";
              };
            };
            diagnostic = {
              "<leader>cd" = {
                action = "open_float";
                desc = "Line diagnostics";
              };
              "[d" = {
                action = "goto_next";
                desc = "Next diagnostic";
              };
              "]d" = {
                action = "goto_prev";
                desc = "Previous diagnostic";
              };
            };
          };
        };
        lsp-status.enable = true;
        lsp-format.enable = true;
        # this is for fixes in the clang lsp...
        clangd-extensions = {
          enable = true;
          enableOffsetEncodingWorkaround = true;
        };
        # displays hints while typing
        lsp-signature = {
          enable = true;
          settings = {
            hint_prefix = " ";
          };
        };
      };
    };
  };
}
