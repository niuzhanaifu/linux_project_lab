#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="${BUILDROOT_DL_DIR:-${ROOT_DIR}/.cache/dl}"
TARGET_DIR="${ROOT_DIR}/docker/buildroot-dl"

if [ ! -d "${SOURCE_DIR}" ]; then
    echo "ERROR: Buildroot download cache not found: ${SOURCE_DIR}" >&2
    echo "Run Lab01 build once first, then run this command again." >&2
    exit 1
fi

mkdir -p "${TARGET_DIR}"
rsync -a --delete --exclude ".gitkeep" "${SOURCE_DIR}/" "${TARGET_DIR}/"

echo "Buildroot download cache copied into Docker preload context:"
echo "  ${TARGET_DIR}"
