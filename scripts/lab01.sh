#!/usr/bin/env bash
set -uo pipefail

run_step() {
    local title="$1"
    local action="$2"

    echo
    echo "==> ${title}"

    if make --no-print-directory "${action}"; then
        echo "OK: ${title}"
        return 0
    fi

    local status=$?
    echo
    echo "LAB01 RESULT: FAIL"
    echo "Failed step: ${title}"
    case "${action}" in
        lab01-build)
            echo "Reason: Buildroot could not build the Lab01 image."
            echo "Action: Read the compiler or Buildroot error above, fix the source/configuration, then run 'make lab01' again."
            ;;
        lab01-run)
            echo "Reason: QEMU could not boot the image to edge-agent output."
            echo "Action: Check artifacts/lab01/serial.log for the boot log."
            ;;
        lab01-check)
            echo "Reason: Lab01 output validation failed."
            echo "Action: Read the reason printed above, fix apps/edge-agent/main.c, then run 'make lab01' again."
            ;;
        *)
            echo "Reason: ${action} failed with exit code ${status}."
            ;;
    esac
    exit "${status}"
}

run_step "Build image" lab01-build
run_step "Boot image in QEMU" lab01-run
run_step "Validate Lab01 output" lab01-check

echo
echo "LAB01 RESULT: PASS"
