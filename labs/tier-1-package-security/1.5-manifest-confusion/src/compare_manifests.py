#!/usr/bin/env python3
from __future__ import annotations

import argparse
import difflib
import json
import subprocess
import tarfile
import tempfile
from pathlib import Path
from urllib.request import urlopen


def _normalized_manifest(payload: dict[str, object]) -> dict[str, object]:
    return {
        "name": payload.get("name"),
        "version": payload.get("version"),
        "dependencies": payload.get("dependencies", {}),
        "devDependencies": payload.get("devDependencies", {}),
        "scripts": payload.get("scripts", {}),
        "bin": payload.get("bin", {}),
    }


def _load_registry_manifest(package_name: str, registry_url: str) -> dict[str, object]:
    with urlopen(f"{registry_url.rstrip('/')}/{package_name}", timeout=10) as response:
        package_data = json.loads(response.read().decode())
    latest_tag = package_data["dist-tags"]["latest"]
    latest_version = package_data["versions"][latest_tag]
    return _normalized_manifest(latest_version)


def _load_tarball_manifest(package_name: str, registry_url: str, workdir: Path) -> dict[str, object]:
    completed = subprocess.run(
        ["npm", "pack", package_name, "--registry", registry_url],
        cwd=workdir,
        capture_output=True,
        text=True,
        check=False,
    )
    tarballs = sorted(workdir.glob("*.tgz"))
    if completed.returncode != 0 or not tarballs:
        raise RuntimeError("Failed to download tarball")
    tarball_path = tarballs[0]
    with tarfile.open(tarball_path) as archive:
        archive.extractall(workdir)
    package_json = workdir / "package" / "package.json"
    return _normalized_manifest(json.loads(package_json.read_text()))


def main() -> int:
    parser = argparse.ArgumentParser(prog="compare_manifests.py")
    parser.add_argument("package_name")
    parser.add_argument("registry_url", nargs="?", default="http://verdaccio:4873")
    args = parser.parse_args()

    print(f"=== Manifest Comparison: {args.package_name} ===")
    print()

    print("[1] Fetching registry metadata...")
    registry_manifest = _load_registry_manifest(args.package_name, args.registry_url)
    registry_text = json.dumps(registry_manifest, indent=2) + "\n"
    print("   Registry says:")
    for line in registry_text.splitlines():
        print(f"     {line}")
    print()

    print("[2] Downloading and extracting tarball...")
    with tempfile.TemporaryDirectory() as temp_dir:
        workdir = Path(temp_dir)
        try:
            tarball_manifest = _load_tarball_manifest(args.package_name, args.registry_url, workdir)
        except RuntimeError as exc:
            print(f"[-] {exc}")
            return 1
    tarball_text = json.dumps(tarball_manifest, indent=2) + "\n"
    print("   Tarball says:")
    for line in tarball_text.splitlines():
        print(f"     {line}")
    print()

    print("[3] Comparing...")
    print()
    diff_lines = list(
        difflib.unified_diff(
            registry_text.splitlines(),
            tarball_text.splitlines(),
            fromfile="registry",
            tofile="tarball",
            lineterm="",
        )
    )
    if not diff_lines:
        print("    [CLEAN] Registry metadata matches tarball contents.")
        print()
        return 0

    print("    [MISMATCH] Registry metadata does NOT match tarball contents!")
    print()
    print("    Differences (--- registry, +++ tarball):")
    for line in diff_lines:
        print(f"     {line}")
    print()
    print("    [!] WARNING: This package may have been tampered with.")
    print("    [!] Do NOT install it without further investigation.")
    print()
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
