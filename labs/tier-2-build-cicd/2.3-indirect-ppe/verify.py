from __future__ import annotations

from shlex import quote

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    repo = context.repos_root / "wl-webapp"
    repo_q = quote(str(repo))
    checksum_file = quote(str(repo / ".ci-checksums"))
    ci_file = quote(str(repo / ".gitea" / "workflows" / "ci.yml"))
    checks = (
        ("CI checksums file exists", f"test -f {checksum_file}"),
        ("Checksums include Makefile", f"test -f {checksum_file} && grep -q 'Makefile' {checksum_file}"),
        (
            "Checksums include scripts/run-tests.sh",
            f"test -f {checksum_file} && grep -q 'scripts/run-tests.sh' {checksum_file}",
        ),
        ("CI config verifies file integrity before execution", f"grep -q 'sha256sum' {ci_file}"),
        ("Checksums match current files", f"test -f {checksum_file} && cd {repo_q} && sha256sum -c .ci-checksums"),
        ("Main CI does not give secrets to PR builds", f"! grep -A 2 '^on:' {ci_file} | grep -q 'pull_request'"),
    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
