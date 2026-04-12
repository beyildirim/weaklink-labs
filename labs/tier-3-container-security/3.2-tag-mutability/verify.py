from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('Deployment uses image digest (@sha256:) instead of tag', "test -f /app/deploy/deployment.yml && grep -q '@sha256:' /app/deploy/deployment.yml"),
        ('No tag-only image references in deployment', "test -f /app/deploy/deployment.yml && ! grep -E 'image:.*:[a-zA-Z0-9._-]+$' /app/deploy/deployment.yml | grep -v '@sha256:'"),
        ('Digest comparison saved to /app/findings.txt', "test -f /app/findings.txt && grep -cE 'sha256:' /app/findings.txt | grep -q '[2-9]'"),
        ('Pinned digest matches the safe image (not the backdoored image)', "test -f /app/deploy/deployment.yml && test -f /app/safe-digest.txt && grep '@sha256:' /app/deploy/deployment.yml | grep -qf /app/safe-digest.txt"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
