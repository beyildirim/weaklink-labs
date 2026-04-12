from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('Dockerfile does not use ENV/ARG for secrets', "test -f /app/Dockerfile.fixed && ! grep -Ei '(ENV|ARG).*(SECRET|API_KEY|TOKEN|PASSWORD)' /app/Dockerfile.fixed"),
        ('Dockerfile uses --mount=type=secret for sensitive data', "test -f /app/Dockerfile.fixed && grep -q 'mount=type=secret' /app/Dockerfile.fixed"),
        ('Secret not present in final image layers', "docker history --no-trunc registry:5000/myapp:secure 2>/dev/null | grep -vi 'SECRET_API_KEY\\|s3cr3t_k3y' && ! docker run --rm registry:5000/myapp:secure env 2>/dev/null | grep -q 'SECRET_API_KEY'"),
        ('.dockerignore blocks sensitive files', "test -f /app/.dockerignore && grep -qE '\\.env|\\.secret|credentials' /app/.dockerignore"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
