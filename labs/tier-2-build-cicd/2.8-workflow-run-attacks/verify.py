from __future__ import annotations

from shlex import quote

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    deploy = quote(str(context.repos_root / "wl-webapp" / ".gitea" / "workflows" / "deploy.yml"))
    checks = (
        ("Deploy workflow exists", f"test -f {deploy}"),
        ("Deploy validates triggering branch is main", f"grep -q 'head_branch.*main\\|branches:.*main' {deploy}"),
        ("Deploy rejects PR-triggered workflows", f"grep -q 'pull_request' {deploy} && grep -q 'exit 1\\|Refusing' {deploy}"),
        ("Deploy does not execute artifact scripts", f"! grep -q 'bash dist/deploy.sh' {deploy}"),
        ("Secrets are not in global env block", f"! awk '/^env:/,/^[a-z]/' {deploy} | grep -q 'secrets\\.'"),
        ("Deploy job uses environment protection", f"grep -q 'environment:' {deploy}"),
    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
