from __future__ import annotations

import hashlib

from weaklink_platform.lab_runtime import (
    VerificationContext,
    fail_check,
    http_get,
    http_ok,
    main_verify,
    pass_check,
    result_from_checks,
)


def run(context: VerificationContext):
    workspace = context.workspace_root / "artifact-demo"
    reference_dir = workspace / "reference"
    reference_tarball = next(reference_dir.glob("demo_lib-*.tar.gz"), None)
    requirements = workspace / "requirements.txt"
    hash_log = workspace / "hash-check.log"
    checks = []
    checks.append(
        pass_check("PyPI private registry is running")
        if http_ok("http://pypi-private:8080/simple/")
        else fail_check("PyPI private registry is running")
    )
    checks.append(
        pass_check("Verdaccio npm registry is running")
        if http_ok("http://verdaccio:4873/-/ping")
        else fail_check("Verdaccio npm registry is running")
    )
    try:
        demo_lib = http_get("http://pypi-private:8080/simple/demo-lib/")
    except Exception:
        demo_lib = ""
    checks.append(
        pass_check("demo-lib package is published to PyPI private")
        if "demo.lib" in demo_lib
        else fail_check("demo-lib package is published to PyPI private")
    )
    checks.append(
        pass_check("OCI container registry is running")
        if http_ok("http://registry:5000/v2/")
        else fail_check("OCI container registry is running")
    )
    checks.append(
        pass_check("Reference artifact exists for known-good demo-lib")
        if reference_tarball and reference_tarball.exists()
        else fail_check("Reference artifact exists for known-good demo-lib")
    )
    requirements_text = requirements.read_text() if requirements.exists() else ""
    checks.append(
        pass_check("requirements.txt pins demo-lib with a SHA256 hash")
        if "demo-lib==1.0.0 --hash=sha256:" in requirements_text
        else fail_check("requirements.txt pins demo-lib with a SHA256 hash")
    )
    if reference_tarball and reference_tarball.exists() and requirements.exists():
        expected_hash = hashlib.sha256(reference_tarball.read_bytes()).hexdigest()
        hash_matches = expected_hash in requirements_text
    else:
        hash_matches = False
    checks.append(
        pass_check("Pinned hash matches the known-good artifact")
        if hash_matches
        else fail_check("Pinned hash matches the known-good artifact")
    )
    checks.append(
        pass_check("Hash verification blocked the tampered registry artifact")
        if hash_log.exists() and "do not match the hashes" in hash_log.read_text().lower()
        else fail_check("Hash verification blocked the tampered registry artifact")
    )
    return result_from_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
