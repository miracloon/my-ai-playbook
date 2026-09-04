#!/usr/bin/env bash
# Write ~/.local/bin/<name> as a detach wrapper around an executable.
# Usage: install-cli-wrapper.sh <name> <executable_abs_path> [fixed_arg...]
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <name> <executable_abs_path> [fixed_arg...]" >&2
  exit 2
fi

NAME="$1"
APP="$2"
shift 2
CLI="${HOME}/.local/bin/${NAME}"

if [[ ! "$NAME" =~ ^[a-z0-9][a-z0-9._+-]*$ ]]; then
  echo "error: invalid command name: $NAME" >&2
  exit 1
fi
if [[ "$APP" != /* || ! -f "$APP" || ! -x "$APP" ]]; then
  echo "error: executable must be an executable absolute file path: $APP" >&2
  exit 1
fi
if [[ -e "$CLI" || -L "$CLI" ]]; then
  if [[ ! -f "$CLI" ]] ||
     ! grep -qF '# managed-by: ry-arch-appimage-deb-install' "$CLI" 2>/dev/null; then
    echo "error: refusing to replace unmanaged CLI: $CLI" >&2
    exit 1
  fi
fi

mkdir -p "${HOME}/.local/bin"
TMP=$(mktemp "${HOME}/.local/bin/.${NAME}.XXXXXX")
cleanup() { rm -f "$TMP"; }
trap cleanup EXIT

{
  echo '#!/usr/bin/env bash'
  echo '# managed-by: ry-arch-appimage-deb-install'
  printf 'APP=%q\n' "$APP"
  printf 'FIXED_ARGS=('
  if [[ $# -gt 0 ]]; then
    printf ' %q' "$@"
  fi
  echo ' )'
  cat <<'TEMPLATE'

# Electron host processes and IDE terminals may export these for their own child
# processes. They must not leak into an independently launched desktop app.
unset ELECTRON_RUN_AS_NODE
unset ELECTRON_NO_ATTACH_CONSOLE

if [[ -n "${RY_ARCH_APP_FOREGROUND:-}" ]]; then
  exec "$APP" "${FIXED_ARGS[@]}" "$@"
fi

for arg in "$@"; do
  case "$arg" in
    -h|--help|-v|--version|--wait|-w)
      exec "$APP" "${FIXED_ARGS[@]}" "$@"
      ;;
  esac
done

nohup "$APP" "${FIXED_ARGS[@]}" "$@" >/dev/null 2>&1 &
disown 2>/dev/null || true
exit 0
TEMPLATE
} > "$TMP"

chmod +x "$TMP"
mv -f "$TMP" "$CLI"
trap - EXIT
echo "cli: $CLI -> $APP"
