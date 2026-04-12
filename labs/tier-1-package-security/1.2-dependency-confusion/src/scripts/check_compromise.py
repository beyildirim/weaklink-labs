#!/usr/bin/env python3
from __future__ import annotations

import subprocess
from pathlib import Path


MARKER_PATH = Path("/tmp/dependency-confusion-pwned")


def _installed_version(package_name: str) -> str | None:
    completed = subprocess.run(
        ["pip", "show", package_name],
        capture_output=True,
        text=True,
        check=False,
    )
    if completed.returncode != 0:
        return None
    for line in completed.stdout.splitlines():
        if line.startswith("Version:"):
            return line.split(":", 1)[1].strip()
    return None


def main() -> int:
    print()
    print("  ==================================================")
    print("  Checking for compromise...")
    print("  ==================================================")
    print()

    if MARKER_PATH.exists():
        print("  [!!!] COMPROMISED!")
        print()
        print("  Contents of /tmp/dependency-confusion-pwned:")
        print("  ---")
        for line in MARKER_PATH.read_text().splitlines():
            print(f"  {line}")
        print("  ---")
        print()
        print("  The malicious setup.py in wl-auth==99.0.0 ran during pip install.")
        print("  In a real attack, this could have:")
        print("    - Exfiltrated AWS/GCP credentials from environment variables")
        print("    - Installed a reverse shell or backdoor")
        print("    - Modified other packages to persist the compromise")
        print("    - Sent your source code to an attacker's server")
    else:
        print("  [OK] Not compromised.")
        print("  /tmp/dependency-confusion-pwned does not exist.")
    print()

    version = _installed_version("wl-auth")
    if version is None:
        print("  wl-auth is not installed.")
    elif version == "1.0.0":
        print(f"  wl-auth version: {version} (legitimate, from private registry)")
    elif version == "99.0.0":
        print(f"  wl-auth version: {version} (MALICIOUS, from public registry)")
    else:
        print(f"  wl-auth version: {version} (unexpected)")
    print()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
