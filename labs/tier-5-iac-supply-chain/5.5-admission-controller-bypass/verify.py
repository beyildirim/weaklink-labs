from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('Gatekeeper config no longer exempts monitoring', "grep -q 'excludedNamespaces' /app/gatekeeper-config/config.yaml && ! awk '/excludedNamespaces:/,/processes:/' /app/gatekeeper-config/config.yaml | grep -q 'monitoring'"),
        ('Policy covers custom resource definitions', "test -f /app/policies/restrict-crds.yaml && grep -q 'CustomResourceDefinition' /app/policies/restrict-crds.yaml"),
        ('Audit policy exists for detecting policy drift', "test -f /app/policies/audit-config.yaml && grep -q 'syncOnly' /app/policies/audit-config.yaml"),
        ('Conftest test files exist for policy testing', 'test -f /app/policies/conftest/policy_test.rego || test -f /app/policies/conftest/test.rego'),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
