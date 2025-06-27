{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.iluminate.enable = lib.mkEnableOption "enables iluminate module";
  };

  config = lib.mkIf config.nixvim-config.plugins.iluminate.enable {
    programs.nixvim = {
      plugins = {
        illuminate = {
          enable = true;
        };
      };
    };
  };
}
