from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('Backdoor filename recorded in /app/findings.txt', "test -f /app/findings.txt && grep -qi 'backdoor\\|malicious\\|reverse.shell\\|implant' /app/findings.txt"),
        ('docker history output saved to /app/history-output.txt', "test -f /app/history-output.txt && grep -qi 'COPY\\|ADD\\|RUN' /app/history-output.txt"),
        ('Hidden layer identified in /app/findings.txt (layer hash or number)', "test -f /app/findings.txt && grep -qE 'sha256:|layer' /app/findings.txt"),
        ('Layer extraction evidence exists (/app/extracted-layers/ directory)', "test -d /app/extracted-layers && ls /app/extracted-layers/ | head -1 | grep -q '.'"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
