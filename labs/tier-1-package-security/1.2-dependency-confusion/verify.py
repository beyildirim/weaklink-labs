from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('No compromise marker (/tmp/dependency-confusion-pwned does not exist)', 'test ! -f /tmp/dependency-confusion-pwned'),
        ('pip.conf uses --index-url (not --extra-index-url)', "grep -q 'index-url' /etc/pip.conf && ! grep -q 'extra-index-url' /etc/pip.conf"),
        ('wl-auth==1.0.0 is installed (legitimate version)', "pip show wl-auth 2>/dev/null | grep -q 'Version: 1.0.0'"),
        ('pip.conf points to private registry only', "grep -q 'pypi-private' /etc/pip.conf && ! grep -q 'pypi-public' /etc/pip.conf"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
