from __future__ import annotations

from shlex import quote

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    repo = context.repos_root / "wl-webapp"
    ci_file = quote(str(repo / ".gitea" / "workflows" / "ci.yml"))
    pr_file = quote(str(repo / ".gitea" / "workflows" / "pr-ci.yml"))
    checks = (
        ("No cache poisoning marker exists", "test ! -f /tmp/cache-poisoned"),
        ("Cache key uses hashFiles for lockfile", f"grep -q 'hashFiles' {ci_file}"),
        ("Main CI does not use restore-keys fallback", f"! grep -q 'restore-keys:' {ci_file}"),
        ("PR builds use isolated cache", f"test -f {pr_file} && grep -q 'pr-\\|pull_request' {pr_file}"),
        ("Main CI does not trigger on pull_request", f"! grep -A 2 '^on:' {ci_file} | grep -q 'pull_request'"),
        ("CI verifies dependency integrity", f"grep -qE '(pip-audit|pip freeze|sha256sum|hash)' {ci_file}"),
    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
