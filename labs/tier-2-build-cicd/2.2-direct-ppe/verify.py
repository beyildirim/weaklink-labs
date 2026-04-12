from __future__ import annotations

from shlex import quote

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    repo = context.repos_root / "wl-webapp"
    ci_file = quote(str(repo / ".gitea" / "workflows" / "ci.yml"))
    pr_file = quote(str(repo / ".gitea" / "workflows" / "pr-ci.yml"))
    codeowners = quote(str(repo / "CODEOWNERS"))
    checks = (
        ("Main CI workflow does not trigger on pull_request", f"! grep -A 2 '^on:' {ci_file} | grep -q 'pull_request'"),
        ("PR-specific workflow exists", f"test -f {pr_file}"),
        ("PR workflow does not use secrets", f"! grep -q 'secrets\\.' {pr_file}"),
        ("Main CI has no global secret env block", f"! awk '/^env:/,/^[a-z]/' {ci_file} | grep -q 'secrets\\.'"),
        ("CODEOWNERS protects .gitea/workflows/", f"grep -q '.gitea/workflows/' {codeowners} 2>/dev/null"),
        ("Deploy job uses environment protection", f"grep -A 5 'deploy:' {ci_file} | grep -q 'environment:'"),
    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
