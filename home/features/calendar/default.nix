{ inputs, config, ... }:
let
  inherit (config.home) username;
  sopsFile = (toString inputs.nix-secrets) + "/sops";
  baseDomain = inputs.nix-secrets.domain;
in
{
  imports = [ ./theme.nix ];

  accounts.calendar = {
    basePath = "${config.xdg.dataHome}/calendar";
    accounts = {
      sync = {
        name = "sync";
        local.encoding = "UTF-8";
        remote = {
          type = "caldav";
          url = "https://dav.${baseDomain}";
          userName = "${username}-radicale";
          passwordCommand = [
            "cat"
            "${config.sops.secrets.caldav.path}"
          ];
        };
        vdirsyncer = {
          enable = true;
          conflictResolution = "remote wins";
          collections = [
            "main"
            "birthdays"
          ];
        };
      };

      main = {
        name = "main";
        local = {
          encoding = "UTF-8";
          path = "${config.xdg.dataHome}/calendar/sync/main";
        };
        khal = {
          enable = true;
          type = "calendar";
          color = "light green";
        };
      };

      birthdays = {
        name = "birthdays";
        local = {
          encoding = "UTF-8";
          path = "${config.xdg.dataHome}/calendar/sync/birthdays";
        };
        khal = {
          enable = true;
          type = "calendar";
          color = "light blue";
        };
      };
    };
  };

  services.vdirsyncer.enable = true;
  programs = {
    vdirsyncer.enable = true;

    khal = {
      enable = true;
      settings = {
        default = {
          timedelta = "5d";
          highlight_event_days = true;
          enable_mouse = true;
        };
        view = {
          frame = "width";
        };
      };
    };
  };

  sops.secrets.caldav.sopsFile = "${sopsFile}/${username}.yaml";
}
