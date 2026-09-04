#!/usr/bin/env bash
# Extract a PNG icon and desktop metadata from an AppImage.
# Usage: extract-icon.sh <appimage_abs_path> <icon_out_abs_path>
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <appimage_abs_path> <icon_out_abs_path>" >&2
  exit 2
fi

APP="$1"
OUT="$2"
if [[ "$APP" != /* || ! -f "$APP" ]]; then
  echo "error: AppImage must be an existing absolute path: $APP" >&2
  exit 1
fi
if [[ "$OUT" != /* ]]; then
  echo "error: icon output must be absolute: $OUT" >&2
  exit 1
fi
if [[ -f "$OUT" && "${FORCE:-}" != "1" ]]; then
  echo "icon: skip (exists) $OUT"
  exit 0
fi

WORK=$(mktemp -d)
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

chmod +x "$APP"
(
  cd "$WORK"
  "$APP" --appimage-extract >/dev/null 2>&1
)

ROOT="$WORK/squashfs-root"
[[ -d "$ROOT" ]] || {
  echo "error: AppImage extraction failed" >&2
  exit 1
}

DESKTOP=$(find "$ROOT" -maxdepth 3 -type f -name '*.desktop' -print -quit)
display_name=""
startup_wmclass=""
categories=""
icon_key=""
if [[ -n "$DESKTOP" ]]; then
  display_name=$(sed -n 's/^Name=//p' "$DESKTOP" | head -1)
  startup_wmclass=$(sed -n 's/^StartupWMClass=//p' "$DESKTOP" | head -1)
  categories=$(sed -n 's/^Categories=//p' "$DESKTOP" | head -1)
  icon_key=$(sed -n 's/^Icon=//p' "$DESKTOP" | head -1)
fi

pick=""
if [[ -n "$icon_key" ]]; then
  pick=$(find "$ROOT" -type f -name "${icon_key}.png" -print0 2>/dev/null |
    xargs -0 -r ls -S 2>/dev/null | head -1 || true)
fi
if [[ -z "$pick" ]]; then
  pick=$(find "$ROOT" -type f -name '*.png' -print0 2>/dev/null |
    xargs -0 -r ls -S 2>/dev/null | head -1 || true)
fi
if [[ -z "$pick" || ! -f "$pick" ]]; then
  echo "error: no PNG icon found in AppImage" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUT")"
cp "$pick" "$OUT"
echo "icon=$OUT"
[[ -n "$display_name" ]] && echo "display_name=$display_name"
[[ -n "$startup_wmclass" ]] && echo "startup_wmclass=$startup_wmclass"
[[ -n "$categories" ]] && echo "categories=$categories"
