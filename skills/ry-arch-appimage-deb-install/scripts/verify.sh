#!/usr/bin/env bash
# Verify a complete managed installation.
# Usage: verify.sh <name> <executable_abs_path> <icon_abs_path>
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <name> <executable_abs_path> <icon_abs_path>" >&2
  exit 2
fi

NAME="$1"
APP="$2"
ICON="$3"
CLI="${HOME}/.local/bin/${NAME}"
DESKTOP="${HOME}/.local/share/applications/${NAME}.desktop"
MANIFEST="/opt/${NAME}/.ry-arch-app-install"
UNREGISTER="/opt/${NAME}/unregister"
failed=0

fail() {
  echo "FAIL: $*" >&2
  failed=1
}

[[ -x "$APP" ]] || fail "app not executable: $APP"
[[ -f "$ICON" ]] || fail "icon missing: $ICON"

if [[ ! -x "$CLI" ]]; then
  fail "CLI missing or not executable: $CLI"
elif ! grep -qF '# managed-by: ry-arch-appimage-deb-install' "$CLI"; then
  fail "CLI is not owned by this skill: $CLI"
elif ! grep -qF "APP=$(printf '%q' "$APP")" "$CLI"; then
  fail "CLI target does not match executable: $APP"
elif grep -qE 'uninstall\\|unregister' "$CLI"; then
  fail "CLI must not intercept application arguments"
fi

resolved=$(command -v "$NAME" 2>/dev/null || true)
[[ "$resolved" == "$CLI" ]] || fail "command resolves to ${resolved:-nothing}, expected $CLI"

if [[ ! -f "$DESKTOP" ]]; then
  fail "desktop missing: $DESKTOP"
else
  grep -qF "Exec=${CLI} %F" "$DESKTOP" ||
    fail "desktop Exec does not match managed CLI"
  grep -qF "Icon=${ICON}" "$DESKTOP" ||
    fail "desktop icon does not match"
  grep -qF 'X-Ry-Arch-App-Install=true' "$DESKTOP" ||
    fail "desktop ownership marker missing"
fi

if [[ ! -f "$MANIFEST" ]]; then
  fail "manifest missing: $MANIFEST"
else
  grep -qF 'manager=ry-arch-appimage-deb-install' "$MANIFEST" ||
    fail "manifest manager mismatch"
  grep -qF "executable=${APP}" "$MANIFEST" ||
    fail "manifest executable mismatch"
fi

[[ -x "$UNREGISTER" ]] || fail "unregister script missing: $UNREGISTER"

if command -v desktop-file-validate >/dev/null 2>&1 && [[ -f "$DESKTOP" ]]; then
  desktop-file-validate "$DESKTOP" ||
    fail "desktop-file-validate rejected $DESKTOP"
fi

[[ "$failed" -eq 0 ]] || exit 1
echo "verify: STRUCTURE OK  name=$NAME  app=$APP  cli=$CLI"
