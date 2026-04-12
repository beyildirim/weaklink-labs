from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('Patch compliance checklist exists', "test -f /app/patch-compliance-checklist.md && grep -qi 'patch\\|remediation\\|SLA' /app/patch-compliance-checklist.md"),
        ('Analysis covers Apache Struts CVE-2017-5638', "test -f /app/analysis.md && grep -qi 'struts' /app/analysis.md && grep -qi 'content.type\\|Content-Type' /app/analysis.md"),
        ('Analysis covers the 2-month patching failure', "test -f /app/analysis.md && grep -qi 'patch\\|remediat' /app/analysis.md && grep -qi 'march\\|may\\|july\\|78.*day\\|two.*month' /app/analysis.md"),
        ('WAF rules detect Struts Content-Type exploitation', "test -f /app/waf-rules.conf && grep -qi 'struts\\|content.type\\|ognl\\|multipart' /app/waf-rules.conf"),
        ('Dependency version monitoring is configured', "test -f /app/dependency-monitor.yml && grep -qi 'struts\\|version\\|alert' /app/dependency-monitor.yml"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
