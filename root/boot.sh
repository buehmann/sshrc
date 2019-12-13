fatal() {
  echo >&2 "$*"
  exit 1
}

boot() {
  if command -v base64; then
    _base64() { base64 "$@"; }
  elif command -v openssl; then
    _base64() { openssl base64 "$@"; }
  else
    fatal "base64 not found"
  fi
} > /dev/null

init() {
  set -euo pipefail
  boot
  export SSHRC_TMP=$(mktemp -d -t sshrc.XXXXXXXX)
  signal_handlers

  export SSHRC_ROOT=$SSHRC_TMP/root
  export SSHRC_HOME=$SSHRC_TMP/home
  mkdir "$SSHRC_ROOT" "$SSHRC_HOME"
}

unpack() {
  _base64 -d | tar xz -C "$1"
}

signal_handlers() {
  trap 'rm -rf "$SSHRC_TMP"' EXIT
}
