{ config, ... }:
let
  palette = config.colorScheme.palette;
in
{
  programs.ghostty = {
    enable = true;
    installBatSyntax = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    settings = {
      # font
      language = "en";
      font-style = "Medium";
      # freaking ghostty ships with noto emoji... need to specify unifont here...
      font-family = [
        ""
        config.fontProfiles.monospace.name
        "Unifont"
      ];
      font-size = config.fontProfiles.monospace.size;
      font-feature = [
        "-liga"
        "-dlig"
        "-calt"
      ];

      # options
      cursor-style = "bar";
      resize-overlay = "never";
      confirm-close-surface = false;
      shell-integration-features = "no-ssh-env,no-ssh-terminfo,no-path";
      app-notifications = "no-clipboard-copy,no-config-reload";
      auto-update = "off";

      # keybinds
      keybind = "ctrl+enter=unbind";

      # theme
      background = "${palette.base00}";
      foreground = "${palette.base06}";
      cursor-color = "${palette.base06}";
      cursor-text = "${palette.base06}";
      selection-background = "#${palette.base03}";
      selection-foreground = "#${palette.base06}";
      palette = with palette; [
        "0=#${base01}"
        "1=#${base08}"
        "2=#${base0B}"
        "3=#${base0A}"
        "4=#${base0D}"
        "5=#${base0E}"
        "6=#${base0C}"
        "7=#${base06}"
        "8=#${base01}"
        "9=#${base08}"
        "10=#${base0B}"
        "11=#${base09}"
        "12=#${base0D}"
        "13=#${base0E}"
        "14=#${base0C}"
        "15=#${base06}"
      ];
    };
  };
}
