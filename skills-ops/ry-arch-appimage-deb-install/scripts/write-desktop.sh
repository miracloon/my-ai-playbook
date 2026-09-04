#!/usr/bin/env bash
# Write a managed user-level desktop entry that calls the managed CLI.
# Usage: write-desktop.sh <name> <icon_abs_path> [display_name] [startup_wmclass] [categories]
set -euo pipefail

if [[ $# -lt 2 || $# -gt 5 ]]; then
  echo "Usage: $0 <name> <icon_abs_path> [display_name] [startup_wmclass] [categories]" >&2
  exit 2
fi

NAME="$1"
ICON="$2"
DISPLAY_NAME="${3:-${NAME^}}"
WMCLASS="${4:-}"
CATEGORIES="${5:-Utility;}"
CLI="${HOME}/.local/bin/${NAME}"

if [[ ! "$NAME" =~ ^[a-z0-9][a-z0-9._+-]*$ ]]; then
  echo "error: invalid command name: $NAME" >&2
  exit 1
fi
if [[ "$ICON" != /* || ! -f "$ICON" ]]; then
  echo "error: icon must be an existing absolute file path: $ICON" >&2
  exit 1
fi
for value in "$DISPLAY_NAME" "$WMCLASS" "$CATEGORIES"; do
  if [[ "$value" == *$'\n'* ]]; then
    echo "error: desktop values cannot contain newlines" >&2
    exit 1
  fi
done
[[ "$CATEGORIES" == *';' ]] || CATEGORIES="${CATEGORIES};"
if [[ ! -x "$CLI" ]] ||
   ! grep -qF '# managed-by: ry-arch-appimage-deb-install' "$CLI" 2>/dev/null; then
  echo "error: managed CLI missing: $CLI" >&2
  exit 1
fi

DESKTOP_DIR="${HOME}/.local/share/applications"
DESKTOP="${DESKTOP_DIR}/${NAME}.desktop"
if [[ -e "$DESKTOP" ]] &&
   ! grep -qF 'X-Ry-Arch-App-Install=true' "$DESKTOP" 2>/dev/null; then
  echo "error: refusing to replace unmanaged desktop: $DESKTOP" >&2
  exit 1
fi

mkdir -p "$DESKTOP_DIR"
TMP=$(mktemp "${DESKTOP_DIR}/.${NAME}.desktop.XXXXXX")
cleanup() { rm -f "$TMP"; }
trap cleanup EXIT

{
  echo "[Desktop Entry]"
  echo "Name=${DISPLAY_NAME}"
  echo "Exec=${CLI} %F"
  echo "Icon=${ICON}"
  echo "Type=Application"
  echo "Terminal=false"
  echo "StartupNotify=false"
  echo "Categories=${CATEGORIES}"
  echo "X-Ry-Arch-App-Install=true"
  if [[ -n "$WMCLASS" ]]; then
    echo "StartupWMClass=${WMCLASS}"
  fi
} > "$TMP"

chmod 0644 "$TMP"
mv -f "$TMP" "$DESKTOP"
trap - EXIT

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
fi
echo "desktop: $DESKTOP"
