{ config, customLib, ... }:
let
  inherit (config.lib.stylix) colors;
  inherit (config.stylix.fonts) monospace;

  rgba = color: "rgba(${customLib.hexToRgb color}, ${config.scheme.opacity})";
in
{
  programs.wofi = {
    enable = true;
    settings = {
      allow_images = true;
      width = "20%";
      hide_scroll = true;
      term = "foot";
      show = "drun";
    };
    style = with colors; ''
      * {
          border: none;
          border-radius: 0px;
          font-family: ${monospace.name};
          font-weight: bold;
      }
      #window {
          border-radius: 10px;
          background-color: ${rgba base00};
          color: #${base05};
      }
      #input {
          border-radius: 10px;
          margin: 10px;
          padding: 10px 15px;
          background-color: ${rgba base01};
          color: #${base04};
          border-color: #${base02};
      }
      #input:focus {
        border-color: #${base0A};
      }
      #outer-box {
        font-weight: bold;
        font-size: 14px;
      }
      #entry {
        margin: 10px;
        padding: 20px 20px;
        border-radius: 10px;
      }
      #entry:hover {
      }
      #entry image {
        padding-right: 10px;
      }
      #entry:nth-child(odd) {
        background-color: rgba(0,0,0,0.0);
      }
      #entry:nth-child(even) {
        background-color: ${rgba colors.base01};
      }
      #entry:selected {
        background-color: ${rgba colors.base02};
      }
    '';
  };
}
