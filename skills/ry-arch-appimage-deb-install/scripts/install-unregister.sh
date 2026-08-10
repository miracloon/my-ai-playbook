#!/usr/bin/env bash
# Install /opt/<name>/unregister. It removes only entries owned by this skill.
# Usage: install-unregister.sh <name>
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
UNREGISTER="${OPT_DIR}/unregister"
mkdir -p "$OPT_DIR"

if [[ -e "$UNREGISTER" ]] &&
   ! grep -qF '# managed-by: ry-arch-appimage-deb-install' "$UNREGISTER" 2>/dev/null; then
  echo "error: refusing to replace unmanaged unregister script: $UNREGISTER" >&2
  exit 1
fi

TMP=$(mktemp "${OPT_DIR}/.unregister.XXXXXX")
cleanup() { rm -f "$TMP"; }
trap cleanup EXIT

cat > "$TMP" <<'TEMPLATE'
#!/usr/bin/env bash
# managed-by: ry-arch-appimage-deb-install
set -euo pipefail

NAME="__NAME__"
CLI="${HOME}/.local/bin/${NAME}"
DESKTOP="${HOME}/.local/share/applications/${NAME}.desktop"
DESKTOP_DIR="${HOME}/.local/share/applications"
blocked=0

if [[ -e "$CLI" || -L "$CLI" ]]; then
  if [[ -f "$CLI" ]] &&
     grep -qF '# managed-by: ry-arch-appimage-deb-install' "$CLI" 2>/dev/null; then
    rm -f "$CLI"
    echo "removed: $CLI"
  else
    echo "refused: unmanaged CLI at $CLI" >&2
    blocked=1
  fi
else
  echo "skip: no managed CLI at $CLI"
fi

if [[ -e "$DESKTOP" ]]; then
  if [[ -f "$DESKTOP" ]] &&
     grep -qF 'X-Ry-Arch-App-Install=true' "$DESKTOP" 2>/dev/null; then
    rm -f "$DESKTOP"
    echo "removed: $DESKTOP"
  else
    echo "refused: unmanaged desktop at $DESKTOP" >&2
    blocked=1
  fi
else
  echo "skip: no managed desktop at $DESKTOP"
fi

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
fi

echo "unregistered: ${NAME}"
echo "kept: /opt/${NAME}/"
[[ "$blocked" -eq 0 ]] || exit 1
TEMPLATE

escaped_name=${NAME//\\/\\\\}
escaped_name=${escaped_name//&/\\&}
sed -i "s|__NAME__|${escaped_name}|g" "$TMP"
chmod +x "$TMP"
mv -f "$TMP" "$UNREGISTER"
trap - EXIT
echo "unregister: $UNREGISTER"
