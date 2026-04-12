from __future__ import annotations

from shlex import quote

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    ci_file = quote(str(context.repos_root / "wl-webapp" / ".gitea" / "workflows" / "ci.yml"))
    checks = (
        ("CI workflow file exists", f"test -f {ci_file}"),
        ("No secrets in global env block", f"! awk '/^env:/,/^[a-z]/' {ci_file} | grep -q 'secrets\\.'"),
        ("Deploy step has scoped DEPLOY_TOKEN", f"grep -A 30 'deploy:' {ci_file} | grep -q 'DEPLOY_TOKEN'"),
        ("Test job does not reference secrets", f"! awk '/^  test:/,/^  [a-z]/' {ci_file} | grep -q 'secrets\\.'"),
        (
            "Build job does not reference secrets",
            f"! awk '/^  build:/,/^  [a-z]/' {ci_file} | grep -q 'SECRET_TOKEN\\|AWS_ACCESS_KEY'",
        ),
        ("Deploy job uses environment protection", f"grep -A 5 'deploy:' {ci_file} | grep -q 'environment:'"),
    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
