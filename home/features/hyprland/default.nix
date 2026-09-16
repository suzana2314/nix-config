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
    hyprshot
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

        builtinMonitor = lib.findFirst (m: m.builtin or false) null config.monitors;

        vars =
          let
            replacements = {
              mod = "SUPER";
              term = "ghostty";
              opacity = toString config.scheme.opacity;
              cursorTheme = config.gtk.cursorTheme.name;
              dataHome = config.xdg.dataHome;
              pictureHome = config.xdg.userDirs.pictures;
              builtinMonitor = if builtinMonitor != null then "desc:${builtinMonitor.description}" else "";
            };
          in
          builtins.replaceStrings (map (n: "@${n}@") (
            builtins.attrNames replacements
          )) (builtins.attrValues replacements) (builtins.readFile config/variables.lua);
      in
      ''
        ${vars}
        ${builtins.readFile config/settings.lua}
        ${builtins.readFile config/animations.lua}
        ${builtins.readFile config/binds.lua}
        ${builtins.readFile config/rules.lua}
        ${lib.concatStringsSep "\n" monitors}
        --- default for monitors without config
        hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
        ${lib.concatStrings workspaces}
      '';
  };
}
