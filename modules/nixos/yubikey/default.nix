# based on: https://unmovedcentre.com/posts/improving-qol-on-nixos-with-yubikey/
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.yubikey;

  homeDirectory = "/home/${cfg.user}";

  yubikey-up =
    let
      yubikeyIds = lib.concatStringsSep " " (
        lib.mapAttrsToList (name: id: "[${name}]=\"${builtins.toString id}\"") config.yubikey.identifiers
      );
    in
    pkgs.writeShellApplication {
      name = "yubikey-up";
      runtimeInputs = builtins.attrValues { inherit (pkgs) gawk yubikey-manager; };
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        serial=$(ykman list | awk '{print $NF}')

        if [ -z "$serial" ]; then
          exit 0
        fi

        declare -A serials=(${yubikeyIds})

        key_name=""
        for key in "''${!serials[@]}"; do
          if [[ $serial == "''${serials[$key]}" ]]; then
            key_name="$key"
          fi
        done

        if [ -z "$key_name" ]; then
          echo WARNING: Unidentified yubikey with serial "$serial". Won\'t link an SSH key.
          exit 0
        fi

        echo "Creating links to ${homeDirectory}/$key_name"
        ln -sf "${homeDirectory}/.ssh/$key_name" ${homeDirectory}/.ssh/yubikey
        ln -sf "${homeDirectory}/.ssh/$key_name.pub" ${homeDirectory}/.ssh/yubikey.pub
      '';
    };
  yubikey-down = pkgs.writeShellApplication {
    name = "yubikey-down";
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      rm ${homeDirectory}/.ssh/id_yubikey
      rm ${homeDirectory}/.ssh/id_yubikey.pub
    '';
  };

in
{
  options.yubikey = {
    enable = lib.mkEnableOption "yubikey support";

    user = lib.mkOption {
      type = lib.types.str;
      description = "Username of the user that will use this module";
    };

    identifiers = lib.mkOption {
      default = { };
      type = lib.types.attrsOf lib.types.int;
      description = "Attrset of Yubikey serial numbers";
      example = lib.literalExample ''
        {
          id1 = 420691337;
          id2 = 133769420;
        }
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.flatten [
      (builtins.attrValues {
        inherit (pkgs)
          yubikey-manager
          pam_u2f
          ;
      })
      yubikey-up
      yubikey-down
    ];

    services = {
      pcscd.enable = true;
      udev.packages = [ pkgs.yubikey-personalization ];

      udev.extraRules = ''
        # Link/unlink ssh key on yubikey add/remove
        SUBSYSTEM=="usb", ACTION=="add", ATTR{idVendor}=="1050", RUN+="${lib.getBin yubikey-up}/bin/yubikey-up"
        # NOTE: Yubikey 4 has a ID_VENDOR_ID on remove, but not Yubikey 5 BIO, whereas both have a HID_NAME.
        # Yubikey 5 HID_NAME uses "YubiKey" whereas Yubikey 4 uses "Yubikey", so matching on "Yubi" works for both
        SUBSYSTEM=="hid", ACTION=="remove", ENV{HID_NAME}=="Yubico Yubi*", RUN+="${lib.getBin yubikey-down}/bin/yubikey-down"
      '';
    };

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
