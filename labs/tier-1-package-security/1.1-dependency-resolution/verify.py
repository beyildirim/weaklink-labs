from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('pip.conf uses --index-url (not --extra-index-url)', "grep -q 'index-url' /etc/pip.conf && ! grep -q 'extra-index-url' /etc/pip.conf"),
        ('pip.conf points to private registry', "grep -q 'pypi-private' /etc/pip.conf"),
        ('Lockfile exists (requirements.lock or frozen output)', 'test -f /app/requirements.lock || test -f /app/requirements.frozen.txt'),
        ('internal-utils==1.0.0 is installed (correct version)', "pip show internal-utils 2>/dev/null | grep -q 'Version: 1.0.0'"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
