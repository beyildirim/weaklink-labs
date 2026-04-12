from __future__ import annotations

from weaklink_platform.lab_runtime import (
    VerificationContext,
    fail_check,
    http_ok,
    main_verify,
    pass_check,
    result_from_checks,
    run_command,
)


def run(context: VerificationContext):
    checks = []
    checks.append(
        pass_check("Local registry is running")
        if http_ok("http://registry:5000/v2/")
        else fail_check("Local registry is running")
    )
    dockerfile = context.workspace_root / "Dockerfile.defended"
    text = dockerfile.read_text() if dockerfile.exists() else ""
    checks.append(
        pass_check("Dockerfile.defended uses digest pinning (@sha256:...)")
        if "@sha256:" in text
        else fail_check("Dockerfile.defended uses digest pinning (@sha256:...)")
    )
    checks.append(
        pass_check("Dockerfile.defended does not reference :latest tag")
        if dockerfile.exists() and ":latest" not in text
        else fail_check("Dockerfile.defended does not reference :latest tag")
    )
    safe_digest_file = context.workspace_root / "safe-digest.txt"
    safe_digest = safe_digest_file.read_text().strip() if safe_digest_file.exists() else ""
    checks.append(
        pass_check("Dockerfile.defended references the safe image digest")
        if safe_digest and safe_digest in text
        else fail_check("Dockerfile.defended references the safe image digest")
    )
    image = run_command(["docker", "images", "-q", "my-defended-app:v1"])
    checks.append(
        pass_check("Defended image 'my-defended-app:v1' was built")
        if image.stdout.strip()
        else fail_check("Defended image 'my-defended-app:v1' was built")
    )
    return result_from_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
