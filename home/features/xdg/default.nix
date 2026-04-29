{ config, ... }:
{
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = null;
      publicShare = null;
      templates = null;
      pictures = "${config.home.homeDirectory}/pictures";
      music = "${config.home.homeDirectory}/music";
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/downloads";
      videos = "${config.home.homeDirectory}/videos";
    };
  };
}
