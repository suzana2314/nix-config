{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.programs.subtui;
  tomlFormat = pkgs.formats.toml { };
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
      source = tomlFormat.generate "subtui-config.toml" cfg.settings;
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
        if [ -f "${cfg.credentials.passwordFile}" ]; then
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
        fi
      ''
    );

  };
}
