{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.comment.enable = lib.mkEnableOption "enable comment module";
  };

  config = lib.mkIf config.nixvim-config.plugins.comment.enable {
    programs.nixvim = {
      plugins = {
        comment = {
          enable = true;
          settings = {
            mappings = {
              basic = true;
              extra = false;
            };
          };
        };
      };
    };
  };
}
