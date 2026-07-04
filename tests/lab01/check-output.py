#!/usr/bin/env python3
import argparse
import re
import sys
from pathlib import Path
from typing import Optional


DEVICE_RE = re.compile(r"edge-agent: device_id=(?P<device_id>student_[0-9_-]+)")
DEVICE_LINE_RE = re.compile(r"edge-agent: device_id=(?P<device_id>\S+)")


def fail(reason: str, detail: Optional[str] = None) -> int:
    print("LAB01 RESULT: FAIL")
    print(f"Reason: {reason}")
    if detail:
        print(f"Detail: {detail}")
    return 1


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate Lab01 serial output.")
    parser.add_argument("logfile", nargs="?", help="Path to QEMU serial log")
    parser.add_argument("--text", help="Raw log text for quick checks")
    args = parser.parse_args()

    if args.text is not None:
        text = args.text
    else:
        if not args.logfile:
            print("ERROR: logfile is required when --text is not used", file=sys.stderr)
            return 2
        path = Path(args.logfile)
        if not path.exists():
            return fail("serial log file was not found", f"Expected path: {path}")
        text = path.read_text(encoding="utf-8", errors="replace")

    if "edge-agent: version=" not in text:
        return fail(
            "edge-agent did not print its version line",
            "The program may not have started, or the init script may not have run.",
        )

    match = DEVICE_RE.search(text)
    if not match:
        raw_match = DEVICE_LINE_RE.search(text)
        if raw_match:
            return fail(
                "device_id format is invalid",
                f"Found '{raw_match.group('device_id')}', expected pattern 'student_[0-9_-]+'.",
            )
        return fail(
            "edge-agent did not print a device_id line",
            "Expected a log line like 'edge-agent: device_id=student_20260001'.",
        )

    print("LAB01 RESULT: PASS")
    print(f"Device ID: {match.group('device_id')}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
