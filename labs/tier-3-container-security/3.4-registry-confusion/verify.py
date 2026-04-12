from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('Deployment uses fully qualified image name (includes registry host)', "test -f /app/deploy/deployment.yml && grep -E 'image: *registry:5000/' /app/deploy/deployment.yml"),
        ('No unqualified image names in deployment', "test -f /app/deploy/deployment.yml && ! grep -E 'image: *[a-z]+:' /app/deploy/deployment.yml | grep -v 'registry:5000'"),
        ('Docker daemon or policy restricts registry sources', "test -f /app/policy/registry-allowlist.yml && grep -q 'registry:5000' /app/policy/registry-allowlist.yml"),
        ('Registry confusion attack documented in /app/findings.txt', "test -f /app/findings.txt && grep -qi 'confusion\\|priority\\|override\\|wrong registry' /app/findings.txt"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
