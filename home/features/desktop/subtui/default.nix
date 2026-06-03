{ inputs, config, ... }:
let
  inherit (config.home) username;
  inherit (config.lib.stylix) colors;
  sopsFile = (toString inputs.nix-secrets) + "/sops";
  baseDomain = inputs.nix-secrets.domain;
in
{
  programs.subtui = {
    enable = true;
    credentials = {
      url = "https://navidrome.${baseDomain}";
      username = "${username}navidrome";
      passwordFile = config.sops.secrets.subsonic.path;
    };
    settings = {
      app = {
        replaygain = "no";
        desktop_notifications = true;
        discord_rich_presence = true;
        default_volume = 80;
        gapless_playback = "yes";
      };
      theme = with colors.withHashtag; {
        subtle = [
          "${base01}"
          "${base01}"
        ];
        highlight = [
          "${base0A}"
          "${base0A}"
        ];
        special = [
          "${base0D}"
          "${base0D}"
        ];
        filtered = [
          "${base01}"
          "${base01}"
        ];
      };

      columns = {
        albums = {
          artist = true;
          name = true;
          song_count = false;
          year = false;
          genre = false;
          rating = false;
          duration = true;
        };
        artists = {
          name = true;
          album_count = true;
          rating = false;
        };
      };
      keybinds = {
        navigation = {
          toggle_selection = [ "V" ];
        };
        media = {
          volume_up = [ "+" ];
          volume_down = [ "-" ];
        };
      };
    };
  };

  sops.secrets.subsonic.sopsFile = "${sopsFile}/${username}.yaml";
}
