{ config, lib, pkgs, ... }:
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
              nixpkgs_fmt.enable = true;
              clang_format = {
                enable = true;
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
                settings = ''
                  {
                    extra_args = { "--fast" },
                  }
                '';
              };
              gofmt = {
                enable = true;
              };
              ocamlformat = {
                enable = true;
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
              statix.enable = true;
            };
            diagnostics = {
              statix.enable = true;
              deadnix.enable = true;
              pylint = {
                enable = true;
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

    home.packages = with pkgs; [
      nixpkgs-fmt
    ];
  };
}
