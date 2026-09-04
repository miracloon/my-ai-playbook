#!/usr/bin/env bash
# Inspect a .deb without installing it or running maintainer scripts.
# Usage: inspect-deb.sh <deb_abs_path>
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <deb_abs_path>" >&2
  exit 2
fi

DEB="$1"
if [[ "$DEB" != /* || ! -f "$DEB" ]]; then
  echo "error: deb must be an existing absolute path: $DEB" >&2
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

WORK=$(mktemp -d)
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT
mkdir -p "$WORK/archive" "$WORK/control"

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
bsdtar -xf "$CONTROL_TAR" -C "$WORK/control"
CONTROL="$WORK/control/control"
if [[ ! -f "$CONTROL" ]]; then
  echo "error: deb control file missing" >&2
  exit 1
fi

field() {
  local key="$1"
  awk -v key="$key" '
    index($0, key ":") == 1 {
      sub("^[^:]+:[[:space:]]*", "")
      print
      exit
    }
  ' "$CONTROL"
}

echo "package=$(field Package)"
echo "version=$(field Version)"
echo "architecture=$(field Architecture)"
echo "depends=$(field Depends)"

scripts=()
for script in preinst postinst prerm postrm; do
  [[ -f "$WORK/control/$script" ]] && scripts+=("$script")
done
if [[ ${#scripts[@]} -eq 0 ]]; then
  echo "maintainer_scripts=none"
else
  printf 'maintainer_scripts=%s\n' "${scripts[*]}"
fi

echo "desktop_entries:"
mapfile -t desktop_members < <(
  bsdtar -tf "$DATA_TAR" |
    awk '{
      normalized=$0
      sub(/^\.\//, "", normalized)
      if (normalized ~ /^usr\/share\/applications\/.*\.desktop$/) print $0
    }'
)
if [[ ${#desktop_members[@]} -eq 0 ]]; then
  echo "  none"
else
  for member in "${desktop_members[@]}"; do
    echo "  path=${member#./}"
    bsdtar -xOf "$DATA_TAR" "$member" |
      awk '
        /^\[Desktop Entry\]$/ { in_entry=1; next }
        /^\[/ { in_entry=0 }
        in_entry && /^(Name|Exec|Icon|StartupWMClass|Categories)=/ {
          print "    " $0
        }
      '
  done
fi

echo "system_integration_paths:"
bsdtar -tf "$DATA_TAR" |
  sed 's|^\./||' |
  awk '
    /^(etc|var)\// ||
    /^usr\/lib\/systemd\// ||
    /^usr\/lib\/udev\// ||
    /^usr\/share\/dbus-1\/system-services\// ||
    /^usr\/share\/polkit-1\// {
      print "  " $0
    }
  '

echo "launch_candidates:"
bsdtar -tf "$DATA_TAR" |
  sed 's|^\./||' |
  awk '
    /^usr\/bin\/[^/]+$/ ||
    /^opt\/[^/]+\/[^/]+$/ {
      print "  " $0
    }
  '
