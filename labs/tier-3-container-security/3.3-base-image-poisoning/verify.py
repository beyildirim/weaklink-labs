from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('Dockerfile FROM uses digest (@sha256:) instead of tag', "grep -E '^FROM .+@sha256:' /app/Dockerfile"),
        ('Backdoor finding documented in /app/findings.txt', "test -f /app/findings.txt && grep -qi 'backdoor\\|malicious\\|poisoned\\|compromised' /app/findings.txt"),
        ('App image rebuilt with safe base (no backdoor present)', 'docker run --rm registry:5000/myapp:secure cat /usr/local/bin/backdoor 2>/dev/null; test \\$? -ne 0'),
        ('Image scan output saved to /app/scan-results.txt', 'test -f /app/scan-results.txt && test -s /app/scan-results.txt'),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
