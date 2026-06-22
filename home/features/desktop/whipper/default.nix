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

      "drive:HL-20" = {
        defeats_cache = true;
        read_offset = 6;
      };

      whipper = {
        eject = "always";
      };

      "whipper.cd.rip" = {
        unknown = true;
        output_directory = "~/My Music";
        track_template = "new/%%A/%%y - %%d/%%t - %%n";
        disc_template = "new/%%A/%%y - %%d/%%A - %%d";
      };
    };
  };
}
