#!/usr/bin/env bash
# Remove only verified ry-appimage-register entries before migrating to the new skill.
# AppImages and icon remain untouched.
# Usage: migrate-legacy-appimage.sh <name>
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <name>" >&2
  exit 2
fi

NAME="$1"
if [[ ! "$NAME" =~ ^[a-z0-9][a-z0-9._+-]*$ ]]; then
  echo "error: invalid command name: $NAME" >&2
  exit 1
fi

OPT_DIR="/opt/${NAME}"
LEGACY_UNINSTALL="${OPT_DIR}/uninstall"
CLI="${HOME}/.local/bin/${NAME}"
DESKTOP="${HOME}/.local/share/applications/${NAME}.desktop"

if [[ ! -f "$LEGACY_UNINSTALL" ]] ||
   ! grep -qF 'ry-appimage-register' "$LEGACY_UNINSTALL"; then
  echo "error: verified legacy uninstall script missing: $LEGACY_UNINSTALL" >&2
  exit 1
fi

if [[ -e "$CLI" || -L "$CLI" ]]; then
  if [[ -L "$CLI" ]]; then
    target=$(readlink -f "$CLI" 2>/dev/null || true)
    if [[ "$target" != "${OPT_DIR}/"* || "$target" != *.AppImage ]]; then
      echo "error: legacy CLI symlink target is not a managed AppImage: $CLI" >&2
      exit 1
    fi
  elif [[ ! -f "$CLI" ]] ||
       ! grep -qF 'ry-appimage-register CLI wrapper' "$CLI"; then
    echo "error: CLI is not a verified legacy entry: $CLI" >&2
    exit 1
  fi
fi

if [[ -e "$DESKTOP" ]]; then
  legacy_exec=$(sed -n 's/^\(Exec=.*\)$/\1/p' "$DESKTOP" | head -1)
  if [[ "$legacy_exec" != "Exec=${OPT_DIR}/"*.AppImage* ]]; then
    echo "error: desktop is not a verified legacy entry: $DESKTOP" >&2
    exit 1
  fi
fi

[[ ! -e "$CLI" && ! -L "$CLI" ]] || {
  rm -f "$CLI"
  echo "removed legacy CLI: $CLI"
}
[[ ! -e "$DESKTOP" ]] || {
  rm -f "$DESKTOP"
  echo "removed legacy desktop: $DESKTOP"
}
rm -f "$LEGACY_UNINSTALL"
echo "removed legacy uninstall: $LEGACY_UNINSTALL"
echo "kept legacy assets: $OPT_DIR"
