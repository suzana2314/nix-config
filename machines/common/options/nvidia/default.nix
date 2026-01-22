{
  hardware.nvidia.prime.amdgpuBusId = "PCI:6:0:0";
  hardware.nvidia.dynamicBoost.enable = true; # https://github.com/NixOS/nixpkgs/issues/364986

  environment.sessionVariables = {
    CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
  };
}
