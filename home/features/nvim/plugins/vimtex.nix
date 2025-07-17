{ config, lib, pkgs, ... }: {

  options = {
    nixvim-config.plugins.vimtex.enable = lib.mkEnableOption "enables vimtex module";
  };

  config = lib.mkIf config.nixvim-config.plugins.vimtex.enable {
    programs.nixvim = {
      plugins = {
        vimtex = {
          enable = true;
          texlivePackage = pkgs.texliveFull;
          settings = {
            view_method = "zathura";
          };
        };
      };
    };
  };
}
