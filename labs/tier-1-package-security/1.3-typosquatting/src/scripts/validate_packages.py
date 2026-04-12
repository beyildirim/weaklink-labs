#!/usr/bin/env python3
from __future__ import annotations

import argparse
import subprocess
from pathlib import Path


def _normalize_package_name(raw_name: str) -> str:
    return raw_name.strip().split("=", 1)[0].split("@", 1)[0].strip().lower()


def main() -> int:
    parser = argparse.ArgumentParser(prog="validate_packages.py")
    parser.add_argument("allowlist", nargs="?", default="/app/allowlist.txt")
    args = parser.parse_args()

    allowlist_path = Path(args.allowlist)
    if not allowlist_path.is_file():
        print(f"[-] Allowlist file not found: {allowlist_path}")
        print("    Create one with: pip freeze | cut -d= -f1 > allowlist.txt")
        return 1

    allowlist = {
        _normalize_package_name(line)
        for line in allowlist_path.read_text().splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    }

    print("[*] Validating installed packages against allowlist...")

    completed = subprocess.run(
        ["pip", "freeze"],
        capture_output=True,
        text=True,
        check=False,
    )
    violations = 0
    for raw_line in completed.stdout.splitlines():
        package_name = _normalize_package_name(raw_line)
        if not package_name:
            continue
        if package_name not in allowlist:
            print(f"    [!] UNAUTHORIZED: {package_name} is not in the allowlist")
            violations += 1

    if violations:
        print(f"[-] Found {violations} unauthorized package(s)!")
        return 1

    print("[+] All packages are authorized.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
