{ config, lib, ... }: {

  options = {
    nixvim-config.plugins.treesitter.enable = lib.mkEnableOption "enables treesitter module";
  };

  config = lib.mkIf config.nixvim-config.plugins.treesitter.enable {
    programs.nixvim = {
      plugins = {
        treesitter = {
          enable = true;
          settings.indent.enable = true;
          nixvimInjections = true;
          folding = false;
        };
      };
    };
  };
}
