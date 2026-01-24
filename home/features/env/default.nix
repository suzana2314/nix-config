{ config, ... }:
{
  # random envs to support XDG base dir
  home.sessionVariables = {
    GOPATH = "${config.xdg.configHome}/go";
    GOMODCACHE = "${config.xdg.cacheHome}/go/mod";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    NODE_REPL_HISTORY = "${config.xdg.dataHome}/node_repl_history";
    NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
    _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${config.xdg.configHome}/java";
    MAVEN_OPTS = "-Dmaven.repo.local=${config.xdg.dataHome}/maven/repository";
    TEXMFHOME = "${config.xdg.dataHome}/texmf";
    TEXMFVAR = "${config.xdg.cacheHome}/texlive/texmf-var";
    TEXMFCONFIG = "${config.xdg.configHome}/texlive/texmf-config";
  };
}
