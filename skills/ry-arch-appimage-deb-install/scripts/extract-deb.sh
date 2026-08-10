#!/usr/bin/env bash
# Extract a .deb into a private version directory. Never runs maintainer scripts.
# Usage: extract-deb.sh <deb_abs_path> <empty_target_abs_path>
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <deb_abs_path> <empty_target_abs_path>" >&2
  exit 2
fi

DEB="$1"
TARGET="${2%/}"
if [[ "$DEB" != /* || ! -f "$DEB" ]]; then
  echo "error: deb must be an existing absolute path: $DEB" >&2
  exit 1
fi
if [[ "$TARGET" != /* || "$TARGET" == "/" ]]; then
  echo "error: target must be a specific absolute path: $TARGET" >&2
  exit 1
fi
if [[ -e "$TARGET" ]]; then
  echo "error: target already exists: $TARGET" >&2
  exit 1
fi
if ! command -v bsdtar >/dev/null 2>&1; then
  echo "error: bsdtar is required" >&2
  exit 1
fi

validate_members() {
  local archive="$1"
  local member normalized
  local unsafe=0
  while IFS= read -r member; do
    normalized="${member#./}"
    if [[ "$normalized" == /* || "$normalized" == ".." ||
          "$normalized" == ../* || "$normalized" == */../* ]]; then
      echo "error: unsafe archive member in $archive: $member" >&2
      unsafe=1
    fi
  done < <(bsdtar -tf "$archive")
  [[ "$unsafe" -eq 0 ]]
}

PARENT=$(dirname "$TARGET")
mkdir -p "$PARENT"
WORK=$(mktemp -d "${PARENT}/.deb-extract.XXXXXX")
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT
mkdir -p "$WORK/archive" "$WORK/payload/root" "$WORK/payload/control"

validate_members "$DEB"
bsdtar -xf "$DEB" -C "$WORK/archive"
CONTROL_TAR=$(find "$WORK/archive" -maxdepth 1 -type f -name 'control.tar*' -print -quit)
DATA_TAR=$(find "$WORK/archive" -maxdepth 1 -type f -name 'data.tar*' -print -quit)
if [[ -z "$CONTROL_TAR" || -z "$DATA_TAR" ]]; then
  echo "error: invalid deb archive (control.tar or data.tar missing)" >&2
  exit 1
fi

validate_members "$CONTROL_TAR"
validate_members "$DATA_TAR"
bsdtar --no-same-owner -xf "$CONTROL_TAR" -C "$WORK/payload/control"
bsdtar --no-same-owner -xf "$DATA_TAR" -C "$WORK/payload/root"

if [[ ! -f "$WORK/payload/control/control" ]]; then
  echo "error: extracted control file missing" >&2
  exit 1
fi

mv "$WORK/payload" "$TARGET"
echo "deb_root=${TARGET}/root"
echo "deb_control=${TARGET}/control"
echo "note=maintainer scripts extracted for inspection only; none executed"
