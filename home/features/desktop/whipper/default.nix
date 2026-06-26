{
  programs.whipper = {
    enable = true;
    settings = {
      main = {
        path_filter_dot = true;
        path_filter_posix = true;
        path_filter_vfat = false;
        path_filter_whitespace = false;
        path_filter_printable = false;
      };

      musicbrainz = {
        server = "https://musicbrainz.org";
      };

      "drive:TSSTcorp%3ACDDVDW%20SE-208GB%20%3ATS00" = {
        vendor = "TSSTcorp";
        model = "CDDVDW SE-208GB";
        release = "TS00";
        defeats_cache = true;
        read_offset = 6;
      };

      whipper = {
        eject = "always";
        drive_auto_close = false;
      };

      "whipper.cd.rip" = {
        unknown = true;
        output_directory = "~/music/music";
        track_template = "%%A/%%d/%%t - %%n";
        disc_template = "%%A/%%d";
        cover_art = "file";
        prompt = true;
      };
    };
  };
}
