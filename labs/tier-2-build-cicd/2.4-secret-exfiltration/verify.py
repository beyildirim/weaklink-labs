from __future__ import annotations

from shlex import quote

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    repo = context.repos_root / "wl-webapp"
    ci_file = quote(str(repo / ".gitea" / "workflows" / "ci.yml"))
    pr_file = quote(str(repo / ".gitea" / "workflows" / "pr-ci.yml"))
    checks = (
        ("No secrets in global env block", f"! awk '/^env:/,/^[a-z]/' {ci_file} | grep -q 'secrets\\.'"),
        ("No echo of secret variables in CI steps", f"! grep -E 'echo.*\\$(DB_PASSWORD|API_KEY|DEPLOY_TOKEN|SECRET)' {ci_file}"),
        ("No secrets written to build artifacts", f"! grep -E '(DB_PASSWORD|API_KEY|DEPLOY_TOKEN).*>' {ci_file}"),
        ("PR workflow exists without secrets", f"test -f {pr_file} && ! grep -q 'secrets\\.' {pr_file}"),
        ("Secrets scoped to deploy step only", f"grep -B 2 -A 5 'DEPLOY_TOKEN' {ci_file} | grep -q 'deploy\\|Deploy'"),
        ("Main CI does not trigger on pull_request", f"! grep -A 2 '^on:' {ci_file} | grep -q 'pull_request'"),
    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
