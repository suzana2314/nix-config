{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.autoUpgrade;
  sendTelegramScript = pkgs.writeScriptBin "send-telegram" ''
    #!/run/current-system/sw/bin/bash
    set -euo pipefail
    MESSAGE="$1"

    if [ ! -f "${cfg.telegram.credentialsFile}" ]; then
        echo "Error: Telegram secrets file not found at ${cfg.telegram.credentialsFile}" >&2
        exit 1
    fi

    BOT_TOKEN=$(grep '^bot_token:' "${cfg.telegram.credentialsFile}" | cut -d':' -f2- | tr -d ' ')
    CHAT_ID=$(grep '^chat_id:' "${cfg.telegram.credentialsFile}" | cut -d':' -f2- | tr -d ' ')
    TOPIC_ID=$(grep '^topic_id:' "${cfg.telegram.credentialsFile}" | cut -d':' -f2- | tr -d ' ' || echo "")

    if [ -z "$BOT_TOKEN" ]; then
        echo "Error: bot_token not found in secrets file" >&2
        exit 1
    fi
    if [ -z "$CHAT_ID" ]; then
        echo "Error: chat_id not found in secrets file" >&2
        exit 1
    fi

    HOST="$(${pkgs.nettools}/bin/hostname)"
    TIMESTAMP="$(${pkgs.coreutils}/bin/date '+%Y-%m-%d %H:%M:%S %Z')"

    FULL_MESSAGE="*$HOST*
    ━━━━━━━━━━━━━━━━━━━━
    *Time:* $TIMESTAMP

    $MESSAGE"

    JSON_PAYLOAD="{
      \"chat_id\": \"$CHAT_ID\",
      \"text\": \"$FULL_MESSAGE\",
      \"parse_mode\": \"Markdown\""

    if [ -n "$TOPIC_ID" ]; then
        JSON_PAYLOAD="$JSON_PAYLOAD,\"message_thread_id\": $TOPIC_ID"
    fi

    JSON_PAYLOAD="$JSON_PAYLOAD}"

    ${pkgs.curl}/bin/curl -s -X POST \
      "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
      -H "Content-Type: application/json" \
      -d "$JSON_PAYLOAD" \
      > /dev/null 2>&1 || true
  '';
in
{
  options.autoUpgrade = {
    enable = lib.mkEnableOption "Enable auto-upgrade";

    user = lib.mkOption {
      type = lib.types.str;
      description = "Owner of the repo";
    };

    repoPath = lib.mkOption {
      type = lib.types.path;
      default = "/etc/nixos";
      description = "Path to the NixOS configuration git repository";
    };

    branch = lib.mkOption {
      type = lib.types.str;
      default = "master";
      description = "Git branch to pull from";
    };

    schedule = {
      dayOfWeek = lib.mkOption {
        type = lib.types.str;
        default = "Sat";
        description = "Day of the week to run the update (Mon, Tue, Wed, Thu, Fri, Sat, Sun)";
      };

      time = lib.mkOption {
        type = lib.types.str;
        default = "06:30";
        description = "Time to run the update in HH:MM format";
      };
    };

    telegram = {
      enable = lib.mkEnableOption "Telegram notifications";

      credentialsFile = lib.mkOption {
        type = lib.types.str;
        default = config.sops.secrets.telegram-secrets.path or "";
        description = "Path to file containing Telegram credentials (bot_token, chat_id, topic_id)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.system.autoUpgrade.enable;
        message = "The system.autoUpgrade option conflicts with this module.";
      }
    ];

    systemd.services.pull-updates = {
      description = "Pulls changes to system config";
      restartIfChanged = false;
      onSuccess = [ "rebuild.service" ];
      startAt = "${cfg.schedule.dayOfWeek} *-*-* ${cfg.schedule.time}:00";
      path =
        [
          pkgs.git
          pkgs.openssh
        ]
        ++ lib.optionals cfg.telegram.enable [
          sendTelegramScript
        ];
      script = ''
        set -euo pipefail

        # FIXME: remove when repo public
        if [ -f "$HOME/.ssh/github" ]; then
          eval "$(ssh-agent -s)"
          ssh-add "$HOME/.ssh/github"
        fi

        send_notification() {
          local status="$1"
          local message="$2"

          ${lib.optionalString cfg.telegram.enable ''
            if [ "$status" = "success" ]; then
              emoji="✅"
            else
              emoji="❌"
            fi
            send-telegram "$emoji *Auto-Update $status*
            $message"
          ''}
        }

        trap 'send_notification "failed" "Git pull failed with error code $?"' ERR

        echo "Starting auto-upgrade pull operation"

        current_branch="$(git branch --show-current)"
        if [ "$current_branch" != "${cfg.branch}" ]; then
          error_msg="Not on ${cfg.branch} branch (currently on $current_branch)"
          echo "Error: $error_msg"
          send_notification "failed" "$error_msg"
          exit 1
        fi

        echo "Pulling changes from origin/${cfg.branch}..."
        old_commit="$(git rev-parse HEAD)"
        if ! git pull --ff-only origin "${cfg.branch}"; then
          error_msg="Git pull failed - there may be uncommitted changes or merge conflicts"
          echo "Error: $error_msg"
          send_notification "failed" "$error_msg"
          exit 1
        fi
        new_commit="$(git rev-parse HEAD)"

        if [ "$old_commit" = "$new_commit" ]; then
          echo "No changes pulled, skipping rebuild"
          send_notification "success" "No updates available - system is up to date"
          exit 0
        fi

        commit_count="$(git rev-list --count "$old_commit..$new_commit")"
        latest_commit="$(git log -1 --pretty=format:'%h: %s' "$new_commit")"

        echo "Changes detected ($commit_count commits), proceeding with rebuild"
        echo "Latest commit: $latest_commit"

        send_notification "success" "Pulled $commit_count new commit(s). Latest: $latest_commit
        Proceeding with system rebuild..."
      '';
      serviceConfig = {
        WorkingDirectory = "${cfg.repoPath}";
        User = cfg.user;
        Type = "oneshot";
      };
      # FIXME: remove when repo public
      environment = {
        HOME = config.users.users.${cfg.user}.home;
        SSH_AUTH_SOCK = "/run/user/${toString config.users.users.${cfg.user}.uid}/ssh-agent";
      };
    };

    systemd.services.rebuild = {
      description = "Rebuilds and activates system config";
      restartIfChanged = false;
      path =
        [
          pkgs.nixos-rebuild
          pkgs.systemd
        ]
        ++ lib.optionals cfg.telegram.enable [
          sendTelegramScript
        ];
      script = ''
        set -euo pipefail

        send_notification() {
          local status="$1"
          local message="$2"

          ${lib.optionalString cfg.telegram.enable ''
            if [ "$status" = "success" ]; then
              emoji="✅"
            else
              emoji="❌"
            fi
            send-telegram "$emoji *Auto-Update $status*

            $message"
          ''}
        }

        trap 'send_notification "failed" "System rebuild failed with error code $?"' ERR

        echo "Starting system rebuild"

        echo "Building new system configuration..."
        /run/wrappers/bin/sudo /run/current-system/sw/bin/nixos-rebuild boot --flake "${cfg.repoPath}"

        echo "Checking if reboot is required..."
        booted="$(readlink /run/booted-system/{initrd,kernel,kernel-modules})"
        built="$(readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})"

        if [ "$booted" = "$built" ]; then
          echo "No kernel changes detected, switching to new configuration..."
          /run/wrappers/bin/sudo /run/current-system/sw/bin/nixos-rebuild switch --flake "${cfg.repoPath}"
          echo "System update completed successfully"
          send_notification "success" "System updated and activated successfully! No reboot required."
        else
          echo "Kernel or initrd changed, scheduling reboot..."
          send_notification "success" "System updated successfully! Kernel/initrd changed - rebooting in 1 minute..."
          /run/wrappers/bin/sudo shutdown -r +1 "System update requires reboot in 1 minute"
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
      };
    };

  };
}
