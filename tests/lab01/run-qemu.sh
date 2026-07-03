#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILD_DIR="${BUILD_DIR:-${ROOT_DIR}/output/qemu-aarch64}"
LOG_FILE="${LOG_FILE:-${ROOT_DIR}/artifacts/lab01/serial.log}"
QEMU_BIN="${QEMU_BIN:-qemu-system-aarch64}"
QEMU_TIMEOUT="${QEMU_TIMEOUT:-90}"
KERNEL="${BUILD_DIR}/images/Image"
ROOTFS="${BUILD_DIR}/images/rootfs.ext2"

if ! command -v "${QEMU_BIN}" >/dev/null 2>&1; then
    echo "ERROR: ${QEMU_BIN} not found." >&2
    echo "Run Lab01 through docker-compose.student.yml or pull the latest lab image." >&2
    exit 1
fi

if [ ! -f "${KERNEL}" ]; then
    echo "ERROR: kernel image not found: ${KERNEL}" >&2
    echo "Run the Lab01 build target first, normally through docker-compose.student.yml." >&2
    exit 1
fi

if [ ! -f "${ROOTFS}" ]; then
    echo "ERROR: rootfs image not found: ${ROOTFS}" >&2
    echo "Run the Lab01 build target first, normally through docker-compose.student.yml." >&2
    exit 1
fi

mkdir -p "$(dirname "${LOG_FILE}")"
: > "${LOG_FILE}"

"${QEMU_BIN}" \
    -M virt \
    -cpu cortex-a53 \
    -m 512M \
    -nographic \
    -nic none \
    -kernel "${KERNEL}" \
    -append "console=ttyAMA0 root=/dev/vda rw panic=-1" \
    -drive "file=${ROOTFS},if=none,format=raw,id=hd0" \
    -device virtio-blk-device,drive=hd0 \
    >"${LOG_FILE}" 2>&1 &

qemu_pid=$!

cleanup() {
    if kill -0 "${qemu_pid}" >/dev/null 2>&1; then
        kill "${qemu_pid}" >/dev/null 2>&1 || true
        wait "${qemu_pid}" >/dev/null 2>&1 || true
    fi
}

trap cleanup EXIT

deadline=$((SECONDS + QEMU_TIMEOUT))
while [ "${SECONDS}" -lt "${deadline}" ]; do
    if grep -q "edge-agent: device_id=" "${LOG_FILE}"; then
        echo "QEMU reached edge-agent output. Log: ${LOG_FILE}"
        exit 0
    fi

    if ! kill -0 "${qemu_pid}" >/dev/null 2>&1; then
        echo "ERROR: QEMU exited before edge-agent output." >&2
        tail -n 80 "${LOG_FILE}" >&2 || true
        exit 1
    fi

    sleep 1
done

echo "ERROR: timeout waiting for edge-agent output." >&2
tail -n 120 "${LOG_FILE}" >&2 || true
exit 1
