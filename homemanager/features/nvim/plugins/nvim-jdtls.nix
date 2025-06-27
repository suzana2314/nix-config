{ config, lib, ... }:
{
  options = {
    nixvim-config.plugins.nvim-jdtls.enable = lib.mkEnableOption "enables nvim-jdtls module";
  };

  config = lib.mkIf config.nixvim-config.plugins.nvim-jdtls.enable {
    programs.nixvim = {
      plugins = {
        jdtls = {
          enable = true;
          settings = {
            cmd = [
              "java"
              "-data"
              "./.jdt-data"
            ];
            root_dir = {
              __raw = "require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'})";
            };
            settings.java.gradle.enabled = true;
          };
        };
      };
    };
  };
}
