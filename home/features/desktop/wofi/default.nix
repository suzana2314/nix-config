{ config, ... }:
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
    style = ''
      * {
          border: none;
          border-radius: 0px;
          font-family: ${config.fontProfiles.monospace.name};
          font-weight: bold;
      }
      #window {
          border-radius: 10px;
      }
      #input {
          border-radius: 10px;
          margin: 10px;
          padding: 10px 15px;
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
    '';
  };
  stylix.targets.wofi.enable = true;
}
