{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config) homelab;
  cfg = homelab.notify-ssh;

  notify-ssh = pkgs.writeShellScriptBin "notify-ssh" ''
    #!/usr/bin/env bash

    if [ "$PAM_TYPE" != "open_session" ]; then
        exit 0
    fi

    URL="https://${cfg.url}/message"
    if [ -f "${cfg.apiKey}" ]; then
        TOKEN=$(cat "${cfg.apiKey}")
    else
        echo "Error: API key file not found at ${cfg.apiKey}" >&2
        exit 1
    fi

    HOST=$(hostname)
    USER="$PAM_USER"
    IP=''${PAM_RHOST:-unknown}

    MESSAGE="SSH Login detected on $HOST from $IP by $USER"

    curl -s -X POST "$URL" \
         -H "X-Gotify-Key: $TOKEN" \
         -H "Content-Type: application/json" \
         -d "{\"message\": \"$MESSAGE\", \"priority\": 10}"
  '';
in
{
  options.homelab.notify-ssh = {
    enable = lib.mkEnableOption "Enable notify-ssh";

    apiKey = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Gotify API key";
    };

    url = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Gotify server URL";
    };

  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ notify-ssh ];

    security.pam.services.sshd.rules.session.notify-ssh = {
      order = config.security.pam.services.sshd.rules.session.systemd.order - 1;
      enable = true;
      control = "optional";
      modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
      args = [
        "log=/var/log/ssh-notify.log"
        "${notify-ssh}/bin/notify-ssh"
      ];
    };
  };
}
