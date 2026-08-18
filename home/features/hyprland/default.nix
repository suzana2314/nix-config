{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./scripts
  ];

  xdg.portal = {
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
    config.hyprland = {
      default = [
        "hyprland"
        "gtk"
      ];
    };
  };

  # fixes screen sharing asking multiple times
  xdg.configFile."hypr/xdph.conf".text = ''
    screencopy {
      allow_token_by_default = true
    }
  '';

  home.packages = with pkgs; [
    hyprpaper
    hyprlock
    hypridle
    hyprpolkitagent
    playerctl
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    configType = "lua";

    extraConfig =
      let
        monitors = map (
          m:
          let
            resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}.0";
            position = "${toString m.x}x${toString m.y}";
          in
          if m.enabled then
            ''
              hl.monitor({
                output = "desc:${m.description}",
                mode = "${resolution}",
                position = "${position}",
                scale = ${toString m.scale},
                bitdepth = ${toString m.bitdepth},
              })
            ''
          else
            ''
              hl.monitor({ output = "desc:${m.description}", disabled = true })
            ''
        ) config.monitors;

        workspaces = lib.flatten (
          map (
            m:
            map (ws: ''
              hl.workspace_rule({ workspace = "${ws}", monitor = "desc:${m.description}" })
            '') m.workspaces
          ) (lib.filter (m: m.enabled && m.workspaces != [ ]) config.monitors)
        );

        vars =
          builtins.replaceStrings
            [ "@mod@" "@term@" "@cursorTheme@" "@dataHome@" "@pictureHome@" ]
            [ "SUPER" "ghostty" config.gtk.cursorTheme.name config.xdg.dataHome config.xdg.userDirs.pictures ]
            (builtins.readFile config/variables.lua);
      in
      ''
        ${vars}
        ${builtins.readFile config/settings.lua}
        ${builtins.readFile config/animations.lua}
        ${builtins.readFile config/binds.lua}
        ${lib.concatStringsSep "\n" monitors}
        ${lib.concatStrings workspaces}
      '';
  };
}
