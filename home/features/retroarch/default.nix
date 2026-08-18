{ pkgs, ... }: {
  programs.retroarch = {
    enable = true;

    # never forget it's all strings...
    settings = {
      video_driver = "vulkan";
      video_fullscreen = "true";

      cheevos_enable = "true";
    };

    cores = {
      # snes
      snes9x = {
        enable = true;
        package = pkgs.libretro.snes9x2010;
      };
    };
  };
}
