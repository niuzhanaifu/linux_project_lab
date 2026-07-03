#!/usr/bin/env bash
set -euo pipefail

missing=0

check_cmd() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "OK: $1"
    else
        echo "MISSING: $1"
        missing=1
    fi
}

check_cmd docker

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    echo "OK: docker compose"
else
    echo "MISSING: docker compose"
    missing=1
fi

if [ "${missing}" -ne 0 ]; then
    echo "Install Docker from docs/environment.md"
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "Docker is installed, but the daemon is not reachable."
    echo "Start Docker, then run this script again."
    exit 1
fi

echo "Student environment looks ready."
echo "Next:"
echo "  docker compose -f docker-compose.student.yml pull lab"
echo "  docker compose -f docker-compose.student.yml run --rm lab make lab01-build"
