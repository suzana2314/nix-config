{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.programs.subtui;
  tomlFormat = pkgs.formats.toml { };
  defaultSettings = {
    app = {
      replaygain = "track";
      desktop_notifications = true;
      discord_rich_presence = true;
      mouse_support = false;
    };
    theme = {
      display_album_art = true;
      subtle = [
        "#D9DCCF"
        "#6B6B6BFF"
      ];
      highlight = [
        "#874BFD"
        "#7D56F4"
      ];
      special = [
        "#43BF6D"
        "#73F59F"
      ];
      filtered = [
        "#A9A9A9"
        "#555555"
      ];
    };
    filters = {
      titles = [ ];
      artists = [ ];
      album_artists = [ ];
      min_duration = 0;
      genres = [ ];
      notes = [ ];
      paths = [ ];
      max_play_count = 0;
      exclude_favorites = false;
      max_rating = 0;
    };
    columns = {
      songs = {
        track_number = false;
        title = true;
        artist = true;
        album = true;
        year = false;
        genre = false;
        rating = false;
        play_count = false;
        duration = true;
      };
      albums = {
        name = true;
        artist = true;
        song_count = false;
        year = false;
        genre = false;
        rating = true;
        duration = true;
      };
      artists = {
        name = true;
        album_count = true;
        rating = true;
      };
    };
    keybinds = {
      global = {
        cycle_focus_next = [ "tab" ];
        cycle_focus_prev = [ "shift+tab" ];
        back = [
          "backspace"
          "esc"
        ];
        help = [ "?" ];
        quit = [ "q" ];
        hard_quit = [ "ctrl+c" ];
      };
      navigation = {
        up = [
          "k"
          "up"
        ];
        down = [
          "j"
          "down"
        ];
        top = [ "gg" ];
        bottom = [ "G" ];
        select = [ "enter" ];
        play_shuffeled = [ "alt+enter" ];
      };
      search = {
        focus_search = [ "/" ];
        filter_next = [ "ctrl+n" ];
        filter_prev = [ "ctrl+b" ];
      };
      library = {
        add_to_playlist = [ "A" ];
        add_rating = [ "R" ];
        go_to_album = [ "ga" ];
        go_to_artist = [ "gr" ];
      };
      media = {
        play_pause = [
          "p"
          "P"
        ];
        next = [ "n" ];
        prev = [ "b" ];
        shuffle = [ "S" ];
        loop = [ "L" ];
        restart = [ "w" ];
        rewind = [ "," ];
        forward = [ ";" ];
        volume_up = [ "v" ];
        volume_down = [ "V" ];
        toggle_media_player = [
          "m"
          "M"
        ];
      };
      queue = {
        toggle_queue_view = [ "Q" ];
        queue_next = [ "N" ];
        queue_last = [ "a" ];
        remove_from_queue = [ "d" ];
        clear_queue = [ "D" ];
        move_up = [ "K" ];
        move_down = [ "J" ];
      };
      favorites = {
        toggle_favorite = [ "f" ];
        view_favorites = [ "F" ];
      };
      other = {
        toggle_notifications = [ "s" ];
        create_share_link = [ "ctrl+s" ];
      };
    };
  };

in
{
  options.programs.subtui = {
    enable = lib.mkEnableOption "subtui";
    package = lib.mkPackageOption pkgs "subtui" { };

    settings = lib.mkOption {
      type = tomlFormat.type;
      default = { };
      example = lib.literalExpression ''
        {
          app = {
            replaygain = "album";
            desktop_notifications = false;
            mouse_support = true;
          };
          theme = {
            display_album_art = false;
            highlight = [ "#FF0000" "#FF6666" ];
          };
        }
      '';
    };

    credentials = {
      url = lib.mkOption {
        type = lib.types.str;
        example = "https://subsonic.example.com";
        description = "URL of the subsonic server.";
      };

      username = lib.mkOption {
        type = lib.types.str;
        example = "alice";
        description = "Username for the server.";
      };

      passwordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        example = lib.literalExpression ''config.sops.secrets."subtui/password".path'';
        description = ''
          Path to a file containing the server password.
          The file must contain only the password, with no trailing newline.
        '';
      };

      password = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "hunter2";
        description = ''
          Password for the server, stored in plain text in the nix store.
        '';
      };

      redactCredentialsInLogs = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.credentials.passwordFile != null || cfg.credentials.password != null;
        message = "programs.subtui: either `credentials.passwordFile` or `credentials.password` must be set.";
      }
    ];

    home.packages = [ cfg.package ];

    xdg.configFile."subtui/config.toml" = {
      source = tomlFormat.generate "subtui-config.toml" (
        lib.recursiveUpdate defaultSettings cfg.settings
      );
    };

    xdg.configFile."subtui/credentials.toml" = lib.mkIf (cfg.credentials.passwordFile == null) {
      source = tomlFormat.generate "subtui-credentials.toml" {
        server = {
          url = cfg.credentials.url;
          username = cfg.credentials.username;
          password = cfg.credentials.password;
        };
        security = {
          redact_credentials_in_logs = cfg.credentials.redactCredentialsInLogs;
        };
      };
    };

    home.activation.subtuiCredentials = lib.mkIf (cfg.credentials.passwordFile != null) (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        install -dm700 "${config.xdg.configHome}/subtui"
        PASSWORD=$(cat "${cfg.credentials.passwordFile}")
        cat > "${config.xdg.configHome}/subtui/credentials.toml" <<EOF
        [server]
        url = '${cfg.credentials.url}'
        username = '${cfg.credentials.username}'
        password = '$PASSWORD'
        [security]
        redact_credentials_in_logs = ${lib.boolToString cfg.credentials.redactCredentialsInLogs}
        EOF
        chmod 600 "${config.xdg.configHome}/subtui/credentials.toml"
      ''
    );

  };
}
