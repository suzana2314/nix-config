# inspiration from -> https://git.notthebe.ee/notthebee/nix-config/src/branch/main/modules/homelab/motd/default.nix
{
  config,
  lib,
  pkgs,
  ...
}:
let

  enabledServices = lib.attrsets.mapAttrsToList (name: value: name) (
    lib.attrsets.filterAttrs (
      name: value: value != "enable" && value ? enable && value.enable
    ) config.homelab.services
  );
  monitoredServices = lib.lists.unique (
    lib.lists.flatten (
      lib.lists.forEach enabledServices (
        x:
        let
          services = config.homelab.services.${x};
        in
        if (services ? monitoredServices) then services.monitoredServices else [ x ]
      )
    )
  );

  motd = pkgs.writeShellScriptBin "motd" ''
    #!/usr/bin/env bash
    [ -z "$SSH_TTY" ] && exit 0
    clear

    source /etc/os-release

    CYAN=$(tput setaf 6)
    YELLOW=$(tput setaf 3)
    GREEN=$(tput setaf 2)
    RED=$(tput setaf 1)
    BLACK=$(tput setaf 0)
    DIM=$(tput dim)
    BOLD=$(tput bold)
    RESET=$(tput sgr0)

    BOX_WIDTH=50
    INNER_WIDTH=$((BOX_WIDTH - 4))

    print_ascii_art() {
        ${''
          cat <<EOF | sed 's/^/ /'
          ''${BOLD}''${CYAN}
          ${config.homelab.motd.asciiArt}''${RESET}
          EOF
        ''}
    }

    print_row() {
        label=$1
        value=$2
        current_len=$(( ''${#label} + 3 + ''${#value} ))
        pad_len=$(( INNER_WIDTH - current_len ))
        printf "''${DIM}│''${RESET} ''${BLACK}%s''${RESET} : ''${BOLD}''${YELLOW}%s''${RESET}%*s ''${DIM}│''${RESET}\n" "$label" "$value" "$pad_len" ""
    }

    print_border() {
        printf "''${DIM}%s" "$1"
        i=0
        while [ $i -lt $((BOX_WIDTH - 2)) ]; do
            printf "─"
            i=$((i+1))
        done
        printf "%s''${RESET}\n" "$2"
    }

    render_service_row() {
      local svc="$1"
      local active_state="$2"
      local display_name="$svc"
      local max_name_len=$((INNER_WIDTH - 12))

      if [ ''${#display_name} -gt $max_name_len ]; then
        display_name="''${display_name:0:$max_name_len}..."
      fi

      case "$active_state" in
        active)
          printf "''${DIM}│''${RESET} ''${GREEN}●''${RESET} %-*s ''${GREEN}[active]  ''${RESET}''${DIM}│''${RESET}\n" \
            "$((INNER_WIDTH - 12))" "$display_name"
          ;;
        failed)
          printf "''${DIM}│''${RESET} ''${RED}●''${RESET} %-*s ''${RED}[failed]  ''${RESET}''${DIM}│''${RESET}\n" \
            "$((INNER_WIDTH - 12))" "$display_name"
          ;;
        inactive)
          printf "''${DIM}│''${RESET} ''${YELLOW}●''${RESET} %-*s ''${YELLOW}[inactive]''${RESET}''${DIM}│''${RESET}\n" \
            "$((INNER_WIDTH - 12))" "$display_name"
          ;;
        *)
          printf "''${DIM}│''${RESET} ''${YELLOW}●''${RESET} %-*s ''${YELLOW}[unknown] ''${RESET}''${DIM}│''${RESET}\n" \
            "$((INNER_WIDTH - 12))" "$display_name"
          ;;
      esac
    }

    print_services() {
      local services=("$@")
      local states
      mapfile -t states < <(systemctl is-active "''${services[@]}" 2>/dev/null)

      local i
      for i in "''${!services[@]}"; do
        render_service_row "''${services[$i]}" "''${states[$i]}"
      done
    }

    # last login info
    if command -v last >/dev/null 2>&1; then
        LAST_LOGIN_RAW=$(last -n 2 "$USER" | sed -n '2p')
        if [ -n "$LAST_LOGIN_RAW" ]; then
            LAST_DATE=$(echo "$LAST_LOGIN_RAW" | awk '{print $4, $5, $6, $7}')
            LAST_IP=$(echo "$LAST_LOGIN_RAW" | awk '{print $3}')
        else
            LAST_DATE="First login"
            LAST_IP="N/A"
        fi
    fi

    # print this work of art :)
    ${lib.optionalString (config.homelab.motd.asciiArt != "") ''
      print_ascii_art
    ''}
    print_border "╭" "╮"
    ${lib.optionalString (config.homelab.motd.asciiArt == "") ''
      print_row "Hostname" "$(hostname)"
    ''}
    print_row "Release" "$PRETTY_NAME"
    print_row "Kernel" "$(uname -rs)"
    print_row "Last login" "$LAST_DATE"
    print_row "From IP" "$LAST_IP"
    print_border "╰" "╯"
    print_border "╭" "╮"
    print_services ${lib.strings.concatStringsSep " " monitoredServices}
    print_border "╰" "╯"
  '';
in
{
  options.homelab.motd = {
    enable = lib.mkEnableOption "motd greeting";
    asciiArt = lib.mkOption {
      type = lib.types.str;
      description = "ASCII art to display at the top of the MOTD";
      default = "";
      example = ''
           _  ___
          / |/ (_)_ __
         /    / /\ \ /
        /_/|_/_//_\_\
      '';
    };
  };

  config = lib.mkIf config.homelab.motd.enable {
    environment.systemPackages = [ motd ];
    environment.etc."ssh/sshrc" = {
      text = ''
        #!/bin/sh
        if command -v motd >/dev/null 2>&1; then
          motd
        fi
      '';
      mode = "0755";
    };
  };
}
