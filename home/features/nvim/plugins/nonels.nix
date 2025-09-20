{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    nixvim-config.plugins.nonels.enable = lib.mkEnableOption "enables none ls config module";
  };

  config = lib.mkIf config.nixvim-config.plugins.nonels.enable {

    programs.nixvim = {
      plugins = {
        none-ls = {
          enable = true;
          enableLspFormat = true;
          sources = {
            formatting = {

              # terraform
              terraform_fmt = {
                enable = true;
                package = null; # pkgs.terraform
              };

              # java
              google_java_format = {
                enable = true;
                package = null; # pkgs.google-java-format
              };

              # nix
              nixfmt = {
                enable = true;
                package = pkgs.nixfmt-rfc-style;
              };

              # c/c++
              clang_format = {
                enable = true;
                package = null; # pkgs.clang-tools
                settings = ''
                  {
                    extra_args = {
                      "--style=Google",
                    },
                  }
                '';
              };

              # python
              black = {
                enable = true;
                package = null; # pkgs.python3.pkgs.black
                settings = ''
                  {
                    extra_args = { "--fast" },
                  }
                '';
              };

              # go
              gofmt = {
                enable = true;
                package = null; # pkgs.go
              };

              # ocaml
              ocamlformat = {
                enable = true;
                package = null; # pkgs.ocamlPackages.ocamlformat
                settings = ''
                  {
                    extra_args = {
                        "--if-then-else",
                        "vertical",
                        "--break-cases",
                        "fit-or-vertical",
                        "--break-string-literals",
                        "never",
                    },
                  }
                '';
              };
            };

            code_actions = {

              # nix
              statix.enable = true;

            };

            diagnostics = {

              # terraform
              terraform_validate = {
                enable = true;
                package = null;
              };

              # nix
              statix.enable = true;
              deadnix.enable = true;

              # python
              pylint = {
                enable = true;
                package = null; # pkgs.pylint
                settings = {
                  extra_args = [
                    "--disable=missing-module-docstring"
                    "--disable=missing-class-docstring"
                    "--disable=missing-function-docstring"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
