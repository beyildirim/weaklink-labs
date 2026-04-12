from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('SBOM shows Log4j as a transitive dependency', "test -f /app/sbom.json && grep -qi 'log4j' /app/sbom.json"),
        ('WAF rules detect JNDI lookup patterns', "test -f /app/waf-rules.conf && grep -qi 'jndi' /app/waf-rules.conf"),
        ('Analysis covers JNDI lookup attack mechanism', "test -f /app/analysis.md && grep -qi 'jndi' /app/analysis.md && grep -qi 'ldap\\|rmi' /app/analysis.md"),
        ('Dependency tree analysis identifies transitive Log4j inclusion', "test -f /app/dependency-tree.txt && grep -qi 'log4j\\|log4j-core' /app/dependency-tree.txt"),
        ('Detection queries cover JNDI pattern matching in logs', "test -f /app/detection-queries.txt && grep -Eqi 'jndi|\\$\\{' /app/detection-queries.txt"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
