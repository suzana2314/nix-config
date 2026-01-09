{ lib, config, ... }:
{
  virtualisation.docker = {
    enable = true;
    liveRestore = false;
  };

  environment.sessionVariables = lib.mkIf config.virtualisation.docker.enable {
    DOCKER_CONFIG = "$XDG_CONFIG_HOME/docker";
  };
}
