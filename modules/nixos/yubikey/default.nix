# based on: https://unmovedcentre.com/posts/improving-qol-on-nixos-with-yubikey/
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.yubikey;
in
{
  options.yubikey = {
    enable = lib.mkEnableOption "yubikey support";

    user = lib.mkOption {
      type = lib.types.str;
      description = "Username of the user that will use this module";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs)
        yubikey-manager
        pam_u2f
        ;
    };

    services.pcscd.enable = true;
    services.udev.packages = [ pkgs.yubikey-personalization ];
    services.yubikey-agent.enable = true;

    security.pam = {
      sshAgentAuth.enable = true;
      u2f = {
        enable = true;
        settings = {
          cue = true;
          # TODO: I need to find a way to not hard code a user here!
          authFile = "/home/${cfg.user}/.config/Yubico/u2f_keys";
        };
      };
      services = {
        login.u2fAuth = true;
        sudo = {
          u2fAuth = true;
          sshAgentAuth = true; # Use SSH_AUTH_SOCK for sudo
        };
      };
    };
  };
}
