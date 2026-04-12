from __future__ import annotations

from shlex import quote

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    ci_file = quote(str(context.repos_root / "wl-webapp" / ".gitea" / "workflows" / "ci.yml"))
    checks = (
        ("No runner compromise marker exists", "test ! -f /tmp/runner-compromised"),
        ("Runner .bashrc has no injected commands", "! grep -qE '(curl|wget|nc|/tmp/|exfil|backdoor)' /runner/workspace/.bashrc"),
        ("Pre-job cleanup hook is installed", "test -x /runner/hooks/pre-job.sh"),
        (
            "Cleanup hook removes temp files",
            "test -f /runner/hooks/pre-job.sh && grep -q 'rm.*runner-compromised' /runner/hooks/pre-job.sh",
        ),
        ("CI config uses container isolation", f"grep -q 'container:' {ci_file}"),
        ("CI verifies clean state before build", f"grep -q 'clean state\\|Verify.*clean\\|verify.*state' {ci_file}"),
    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
