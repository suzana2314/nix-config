{
  hardware.nvidia.modesetting.enable = true;

  environment.sessionVariables = {
    CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
  };
}
