{ config, lib, ... }:
{

  options = {
    nixvim-config.plugins.lualine.enable = lib.mkEnableOption "enables lualine module";
  };

  config = lib.mkIf config.nixvim-config.plugins.lualine.enable {
    programs.nixvim = {
      plugins = {
        lualine = {
          enable = true;
          settings = {
            options = {
              globalstatus = true;
              theme = "gruvbox";
              section_separators = {
                left = "";
                right = "";
              };
              component_separators = {
                left = "";
                right = "";
              };
            };
            sections = {
              lualine_a = [
                {
                  __unkeyed-1 = "mode";
                  icon = "";
                }
              ];
              lualine_b = [
                {
                  __unkeyed-1 = "branch";
                  icon = "";
                }
                {
                  __unkeyed-1 = "diff";
                  symbols = {
                    added = " ";
                    modified = " ";
                    removed = " ";
                  };
                }
              ];
              lualine_c = [
                {
                  __unkeyed-1 = "diagnostics";
                  sources = [ "nvim_lsp" ];
                  symbols = {
                    error = " ";
                    warn = " ";
                    info = " ";
                    hint = "󰝶 ";
                  };
                }
              ];
              lualine_x = [
                {
                  __unkeyed-1 = "filetype";
                  icon_only = true;
                  separator = "";
                  padding = {
                    left = 1;
                    right = 1;
                  };
                }
                {
                  __unkeyed-1 = "filename";
                  path = 1;
                }
              ];
              lualine_y = [
                {
                  __unkeyed-1 = "progress";
                }
              ];
              lualine_z = [
                {
                  __unkeyed-1 = "location";
                }
              ];
            };
          };
        };
      };
    };
  };
}
