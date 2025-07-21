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
    if [ ! -f "${cfg.credentialsFile}" ]; then
        echo "Error: Secrets file not found at ${cfg.credentialsFile}" >&2
        exit 1
    fi
    BOT_TOKEN=$(grep '^bot_token:' "${cfg.credentialsFile}" | cut -d':' -f2- | tr -d ' ')
    CHAT_ID=$(grep '^chat_id:' "${cfg.credentialsFile}" | cut -d':' -f2- | tr -d ' ')
    TOPIC_ID=$(grep '^topic_id:' "${cfg.credentialsFile}" | cut -d':' -f2- | tr -d ' ' || echo "")

    if [ -z "$BOT_TOKEN" ]; then
        echo "Error: bot_token not found in secrets file" >&2
        exit 1
    fi

    if [ -z "$CHAT_ID" ]; then
        echo "Error: chat_id not found in secrets file" >&2
        exit 1
    fi

    URL="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"
    HOST=$(hostname)
    USER="$PAM_USER"
    IP=''${PAM_RHOST:-unknown}
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S %Z')
    MESSAGE="🔐 *$HOST*
    ━━━━━━━━━━━━━━━━━━━━
    *User:* \`$USER\`
    *From:* \`$IP\`
    *When:* $TIMESTAMP
    ━━━━━━━━━━━━━━━━━━━━"

    JSON_PAYLOAD="{
      \"chat_id\": \"$CHAT_ID\",
      \"text\": \"$MESSAGE\",
      \"parse_mode\": \"Markdown\""
    if [ -n "$TOPIC_ID" ]; then
        JSON_PAYLOAD="$JSON_PAYLOAD,\"message_thread_id\": $TOPIC_ID"
    fi

    JSON_PAYLOAD="$JSON_PAYLOAD}"
    curl -s -X POST "$URL" \
         -H "Content-Type: application/json" \
         -d "$JSON_PAYLOAD"
  '';
in
{
  options.homelab.notify-ssh = {
    enable = lib.mkEnableOption "Enable SSH notifications via Telegram";
    credentialsFile = lib.mkOption {
      type = lib.types.str;
      default = config.sops.secrets.telegram-secrets.path or "";
      description = "Path to file containing Telegram credentials (bot_token, chat_id, topic_id)";
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
