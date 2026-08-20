{ config, ... }: {
  services.syncthing = {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      devices = {
        "cube".id = "G5MHPDQ-DBIZ2HU-J3OCMYT-CO4ISDD-ZVNCSIW-NAEJRNY-LETVMXJ-4L26EQ4";
      };
      folders = {
        "Saves" = {
          path = "${config.xdg.userDirs.documents}/games/saves";
          devices = [ "cube" ];
        };
      };
    };
  };
}
