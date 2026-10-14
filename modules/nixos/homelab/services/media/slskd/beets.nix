{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config) homelab;
  service = "slskd";
  cfg = homelab.services.${service};
  settingsFormat = pkgs.formats.yaml { };
  beet = pkgs.writeScriptBin "beet" ''
    sudo -u ${homelab.user} BEETSDIR=${homelab.services.slskd.musicDir}/.beets ${lib.getExe pkgs.beets} -c ${config.homelab.services.slskd.beetsConfigFile} "$@"
  '';
  beetsConfig = {
    directory = "${config.homelab.services.slskd.musicDir}";
    library = "${config.homelab.services.slskd.musicDir}/.beets/beets.db";
    plugins = [
      "duplicates"
      "embedart"
      "fetchart"
      "lastgenre"
      "lyrics"
      "info"
    ];
    terminal_encoding = "utf-8";
    threaded = true;
    ui.color = true;
    import = {
      write = true;
      copy = true;
      move = false;
      autotag = true;
      duplicate_action = "merge";
      bell = true;
      log = "/dev/null";
      quiet = true;
      quiet_fallback = "asis";
    };
    original_date = true;
    embedart.auto = true;
    aunique = {
      keys = "albumartist album";
      disambiguators = "albumtype year label catalognum albumdisambig releasegroupdisambig";
      bracket = "[]";
    };
    fetchart = {
      auto = true;
      sources = [
        "filesystem"
        "coverart"
        "itunes"
      ];
    };
    lastgenre = {
      auto = true;
      source = "album";
    };
    lyrics = {
      synced = true;
      sources = [
        "lrclib"
        "genius"
      ];
    };
  };
in
{
  config = lib.mkIf cfg.enable {
    homelab.services.slskd.beetsConfigFile = settingsFormat.generate "beets.yaml" beetsConfig;
    environment.systemPackages = [ beet ];
  };
}
