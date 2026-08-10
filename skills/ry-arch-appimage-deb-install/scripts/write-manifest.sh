#!/usr/bin/env bash
# Write the installation record used to recognize managed history.
# Usage: write-manifest.sh <name> <appimage|deb> <version> <source_abs> <executable_abs>
set -euo pipefail

if [[ $# -ne 5 ]]; then
  echo "Usage: $0 <name> <appimage|deb> <version> <source_abs> <executable_abs>" >&2
  exit 2
fi

NAME="$1"
FORMAT="$2"
VERSION="$3"
SOURCE="$4"
APP="$5"
OPT_DIR="/opt/${NAME}"
MANIFEST="${OPT_DIR}/.ry-arch-app-install"

if [[ ! "$NAME" =~ ^[a-z0-9][a-z0-9._+-]*$ ]]; then
  echo "error: invalid command name: $NAME" >&2
  exit 1
fi
if [[ "$FORMAT" != "appimage" && "$FORMAT" != "deb" ]]; then
  echo "error: unsupported format: $FORMAT" >&2
  exit 1
fi
if [[ "$SOURCE" != /* || ! -f "$SOURCE" ]]; then
  echo "error: source must be an existing absolute file path: $SOURCE" >&2
  exit 1
fi
if [[ "$APP" != /* || ! -x "$APP" ]]; then
  echo "error: executable must be an executable absolute path: $APP" >&2
  exit 1
fi
for value in "$VERSION" "$SOURCE" "$APP"; do
  if [[ "$value" == *$'\n'* ]]; then
    echo "error: manifest values cannot contain newlines" >&2
    exit 1
  fi
done

mkdir -p "$OPT_DIR"
if [[ -e "$MANIFEST" ]] &&
   ! grep -qF 'manager=ry-arch-appimage-deb-install' "$MANIFEST" 2>/dev/null; then
  echo "error: refusing to replace unmanaged manifest: $MANIFEST" >&2
  exit 1
fi
TMP=$(mktemp "${OPT_DIR}/.manifest.XXXXXX")
cleanup() { rm -f "$TMP"; }
trap cleanup EXIT

{
  echo "manager=ry-arch-appimage-deb-install"
  echo "name=${NAME}"
  echo "format=${FORMAT}"
  echo "version=${VERSION}"
  echo "source=${SOURCE}"
  echo "executable=${APP}"
  echo "cli=${HOME}/.local/bin/${NAME}"
  echo "desktop=${HOME}/.local/share/applications/${NAME}.desktop"
} > "$TMP"

chmod 0644 "$TMP"
mv -f "$TMP" "$MANIFEST"
trap - EXIT
echo "manifest: $MANIFEST"
