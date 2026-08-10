#!/usr/bin/env bash
# Refuse execution outside Arch Linux or an Arch-derived environment.
set -euo pipefail

if [[ ! -r /etc/os-release ]]; then
  echo "error: cannot identify operating system (/etc/os-release missing)" >&2
  exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release

is_arch=0
if [[ "${ID:-}" == "arch" ]]; then
  is_arch=1
else
  for like in ${ID_LIKE:-}; do
    [[ "$like" == "arch" ]] && is_arch=1
  done
fi

if [[ "$is_arch" -ne 1 ]] || ! command -v pacman >/dev/null 2>&1; then
  echo "error: ry-arch-appimage-deb-install only supports Arch Linux" >&2
  exit 1
fi

echo "platform: Arch Linux (${PRETTY_NAME:-${ID}})"
