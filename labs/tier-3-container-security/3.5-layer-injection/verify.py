from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('Injected layer identified in /app/findings.txt', "test -f /app/findings.txt && grep -qi 'inject\\|extra layer\\|added layer\\|reverse.shell\\|backdoor' /app/findings.txt"),
        ('Layer count comparison documented', "test -f /app/findings.txt && grep -qE '[0-9]+ layer' /app/findings.txt"),
        ('Injected layer content extracted to /app/extracted-layers/', "test -d /app/extracted-layers && find /app/extracted-layers -type f | head -1 | grep -q '.'"),
        ('Clean image signed (cosign signature or signing record exists)', "test -f /app/cosign-output.txt && grep -qi 'signing\\|Pushing signature\\|tlog entry' /app/cosign-output.txt"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
