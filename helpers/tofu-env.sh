_tofu_env() {
  local file token passphrase

  if [ -z "${SECRETS_LOCATION:-}" ]; then
    echo "tofu-env: SECRETS_LOCATION is not set" >&2
    return 1
  fi

  file="$SECRETS_LOCATION/tf/hetzner-storagebox.yaml"

  token=$(sops -d --extract '["hcloud_token"]' "$file")
  passphrase=$(sops -d --extract '["state_passphrase"]' "$file")

  export TF_VAR_hcloud_token="$token"
  export TF_VAR_state_passphrase="$passphrase"
}

_tofu_env
unset -f _tofu_env
