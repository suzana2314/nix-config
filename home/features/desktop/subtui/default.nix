{ inputs, config, ... }:
let
  inherit (config.home) username;
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
        desktop_notifications = false;
        discord_rich_presence = false;
      };
      theme =
        let
          inherit (config.colorScheme) palette;
        in
        {
          subtle = [
            "#${palette.base01}"
            "#${palette.base01}"
          ];
          highlight = [
            "#${palette.base0A}"
            "#${palette.base0A}"
          ];
          special = [
            "#${palette.base0D}"
            "#${palette.base0D}"
          ];
          filtered = [
            "#${palette.base01}"
            "#${palette.base01}"
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
    };
  };

  sops.secrets.subsonic.sopsFile = "${sopsFile}/${username}.yaml";
}
