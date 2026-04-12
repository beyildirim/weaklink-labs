from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('No local-exec provisioners in Terraform modules', "! grep -r 'local-exec' /app/infra/modules/"),
        ('Module source uses pinned version or local path', "grep -E '(version\\s*=|\\.\\/modules\\/)' /app/infra/main.tf"),
        ('Terraform lock file exists with provider hashes', "test -f /app/infra/.terraform.lock.hcl && grep -q 'h1:' /app/infra/.terraform.lock.hcl"),
        ('No curl/wget/exfiltration commands in .tf files', "! grep -r -E '(curl|wget|nc |ncat|/dev/tcp)' /app/infra/ --include='*.tf'"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
