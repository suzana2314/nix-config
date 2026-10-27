{ inputs, config, ... }:
let
  inherit (config.home) username;
  sopsFile = (toString inputs.nix-secrets) + "/sops";
  baseDomain = inputs.nix-secrets.domain;
in
{
  imports = [ ./theme.nix ];

  accounts = {
    calendar = {
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
              "${config.sops.secrets.dav.path}"
            ];
          };
          vdirsyncer = {
            enable = true;
            conflictResolution = "remote wins";
            collections = [
              "main"
              "holidays"
              "benfica"
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

        holidays = {
          name = "holidays";
          local = {
            encoding = "UTF-8";
            path = "${config.xdg.dataHome}/calendar/sync/holidays";
          };
          khal = {
            enable = true;
            type = "calendar";
            color = "yellow";
          };
        };

        benfica = {
          name = "benfica";
          local = {
            encoding = "UTF-8";
            path = "${config.xdg.dataHome}/calendar/sync/benfica";
          };
          khal = {
            enable = true;
            type = "calendar";
            color = "dark red";
          };
        };
      };
    };

    contact = {
      basePath = "${config.xdg.dataHome}/contacts";
      accounts = {
        sync = {
          name = "sync";
          local = {
            type = "filesystem";
            fileExt = ".vcf";
          };
          remote = {
            type = "carddav";
            url = "https://dav.${baseDomain}";
            userName = "${username}-radicale";
            passwordCommand = [
              "cat"
              "${config.sops.secrets.dav.path}"
            ];
          };
          vdirsyncer = {
            enable = true;
            conflictResolution = "remote wins";
            collections = [ "contacts" ];
          };
        };
        main = {
          local = {
            type = "filesystem";
            fileExt = ".vcf";
            path = "${config.xdg.dataHome}/contacts/sync";
          };
          khard = {
            enable = true;
            defaultCollection = "contacts";
          };
          khal = {
            enable = true;
            collections = [ "contacts" ];
            color = "light blue";
          };
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

    khard = {
      enable = true;
      settings.general = {
        default_action = "list";
      };
    };
  };

  sops.secrets.dav.sopsFile = "${sopsFile}/${username}.yaml";
}
