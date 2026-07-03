#!/usr/bin/env bash
set -euo pipefail

PRELOAD_DL_DIR="${PRELOAD_BUILDROOT_DL_DIR:-/opt/buildroot-dl}"
TARGET_DL_DIR="${BUILDROOT_DL_DIR:-/work/.cache/dl}"

if [ -d "${PRELOAD_DL_DIR}" ]; then
    mkdir -p "${TARGET_DL_DIR}"
    rsync -a --ignore-existing "${PRELOAD_DL_DIR}/" "${TARGET_DL_DIR}/"
fi

exec "$@"
