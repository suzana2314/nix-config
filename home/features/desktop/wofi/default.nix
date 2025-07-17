{ config, ... }:
{
  programs.wofi = with config.colorScheme.palette; {
    enable = true;
    settings = {
      allow_images = false;
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
      		color: #${base0C}
      }
      #window {
          border-radius: 10px;
          background: #${base00};
      }
      #input {
          border-radius: 10px;
          margin: 10px;
          padding: 10px 15px;
          background: #282828;
          color: #${base0C};
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
      #entry:selected {
        background-color: #${base0D};
        color: #${base06};
      }
      #entry:hover {
      }
    '';
  };
}
