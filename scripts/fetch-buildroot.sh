#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${BUILDROOT_VERSION:-2026.02.3}"
CACHE_DIR="${ROOT_DIR}/.cache"
TARBALL="${CACHE_DIR}/buildroot-${VERSION}.tar.xz"
BUILDROOT_DIR="${CACHE_DIR}/buildroot-${VERSION}"
URL="https://buildroot.org/downloads/buildroot-${VERSION}.tar.xz"

mkdir -p "${CACHE_DIR}"

if [ -d "${BUILDROOT_DIR}" ]; then
    echo "Buildroot already exists: ${BUILDROOT_DIR}"
    exit 0
fi

if [ ! -f "${TARBALL}" ]; then
    echo "Downloading ${URL}"
    if command -v curl >/dev/null 2>&1; then
        curl -L "${URL}" -o "${TARBALL}"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "${TARBALL}" "${URL}"
    else
        echo "curl or wget is required to download Buildroot." >&2
        exit 1
    fi
fi

tar -C "${CACHE_DIR}" -xf "${TARBALL}"
echo "Buildroot ready: ${BUILDROOT_DIR}"

