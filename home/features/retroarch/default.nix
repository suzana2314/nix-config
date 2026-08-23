{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (config.home) username;
  sopsFile = (toString inputs.nix-secrets) + "/sops";
  path = config.xdg.userDirs.documents;
in
{
  programs.retroarch = {
    enable = true;
    # never forget it's all strings...
    settings = {
      config_save_on_exit = "true";

      video_driver = "vulkan";
      video_fullscreen = "true";

      cheevos_enable = "true";
      cheevos_username = "suzana2314";
      cheevos_hardcore_mode_enable = "true";
      cheevos_badges_enable = "true";
      cheevos_unlock_sound_enable = "false";

      menu_driver = "xmb";

      rgui_browser_directory = "${path}/games/roms";
      system_directory = "${path}/games/bios";
      savefile_directory = "${path}/games/saves";
      savefiles_in_content_dir = "false";
      sort_savefiles_by_content_enable = "true";
      sort_savefiles_enable = "false";
      sort_savestates_by_content_enable = "true";
      sort_savestates_enable = "false";
    };

    cores = {
      # snes
      snes9x = {
        enable = true;
        package = pkgs.libretro.snes9x;
      };
    };
  };

  sops.secrets.retroachievements.sopsFile = "${sopsFile}/${username}.yaml";

  home.activation.retroarchCheevosPassword = lib.hm.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
    cfg="$HOME/.config/retroarch/retroarch.cfg"
    mkdir -p "$(dirname "$cfg")"
    touch "$cfg"
    ${pkgs.gnused}/bin/sed -i "\|^cheevos_password|d" "$cfg"
    printf 'cheevos_password = "%s"\n' "$(cat ${config.sops.secrets.retroachievements.path})" >> "$cfg"
    chmod 600 "$cfg"
  '';
}
