fatal() {
  echo >&2 "$*"
  exit 1
}

if [ "${BASH_VERSINFO-0}" -lt 4 ]; then
  fatal "$HOSTNAME: bash >= 4.0 is required. Found $BASH_VERSION instead."
fi

boot() {
  if command -v openssl; then
    base64() { openssl base64 "$@"; }
  elif command -v base64; then
    base64() { command base64 "$@"; }
  else
    fatal "base64 not found"
  fi
} > /dev/null

init() {
  set -euo pipefail
  boot
  SSHRC_TMP=$(mktemp -d -t sshrc.XXXXXXXX)
  signal_handlers
  export SSHRC_TMP

  export SSHRC_ROOT=$SSHRC_TMP/root
  export SSHRC_HOME=$SSHRC_TMP/home
  mkdir "$SSHRC_ROOT" "$SSHRC_HOME"
}

unpack() {
  base64 -d | tar xz -C "$1"
}

signal_handlers() {
  trap 'rm -rf "$SSHRC_TMP"' EXIT
}
