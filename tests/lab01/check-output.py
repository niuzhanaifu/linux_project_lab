#!/usr/bin/env python3
import argparse
import re
import sys
from pathlib import Path


DEVICE_RE = re.compile(r"edge-agent: device_id=(?P<device_id>student_[0-9_-]+)")


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
            print(f"ERROR: log file not found: {path}", file=sys.stderr)
            return 2
        text = path.read_text(encoding="utf-8", errors="replace")

    if "edge-agent: version=" not in text:
        print("LAB01 FAIL: edge-agent version line not found")
        return 1

    match = DEVICE_RE.search(text)
    if not match:
        print("LAB01 FAIL: device_id must match student_[0-9_-]+")
        return 1

    print(f"LAB01 PASS: {match.group('device_id')}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

