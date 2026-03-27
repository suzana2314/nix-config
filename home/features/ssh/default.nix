{ inputs, lib, ... }:
let
  inherit (inputs.nix-secrets) sshCfg;

  pathToKeys = ../../../machines/common/users/super/keys/ssh;

  yubikeys = lib.lists.forEach (builtins.attrNames (builtins.readDir pathToKeys)) (
    key: lib.substring 0 (lib.stringLength key - lib.stringLength ".pub") key
  );

  yubikeyPublicKeys = lib.attrsets.mergeAttrsList (
    lib.lists.map (key: {
      ".ssh/${key}.pub".source = "${pathToKeys}/${key}.pub";
    }) yubikeys
  );
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    extraConfig = ''
      Include ~/.ssh/extra_config
    '';
    matchBlocks =
      let
        gitForge = {
          user = "git";
          identitiesOnly = true;
          identityFile = "~/.ssh/yubikey";
        };
      in
      {
        "*" = {
          controlMaster = "auto";
          controlPath = "~/.ssh/sockets/S.%r@%h:%p";
          controlPersist = "15m";
          serverAliveCountMax = 3;
          serverAliveInterval = 5;
          hashKnownHosts = true;
          addKeysToAgent = "yes";

          extraOptions = {
            SetEnv = "TERM=xterm-256color";
            UpdateHostKeys = "ask";
          };
        };
        "github.com" = gitForge;
        "codeberg.org" = gitForge;
      }
      // sshCfg;
  };

  home.file = {
    ".ssh/sockets/.keep".text = "#home manager managed";
  }
  // yubikeyPublicKeys;
}
