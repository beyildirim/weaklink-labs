# Lab 5.5: Kubernetes Admission Controller Bypass

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step done">Defend</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Detect</span>
</div>

<div class="no-terminal-notice">Reference material. No terminal needed.</div>

## Catching Admission Controller Bypasses

Bypasses leave traces in Kubernetes audit logs. Key signals: resources in exempt namespaces, uncovered resource types, and mutations changing security-sensitive fields.

**Key indicators:**

- Pod creation in `kube-system` by non-system service accounts
- CRDs with privileged security contexts
- Patch operations adding `privileged: true`, `hostNetwork`, or `hostPID`
- Webhook failures (HTTP 500) with `failurePolicy: Ignore`
- Gatekeeper/Kyverno audit violations not caught at admission time

| Indicator | What It Means |
|-----------|---------------|
| Webhook endpoint returning 5xx errors | Admission controller failing, resources may bypass policy |
| DNS query from `kube-system` pod to external domain | Workload in exempt namespace reaching attacker infrastructure |
| Privileged container making host-level network connections | Bypassed pod accessing node network stack |

### CI Integration

Test policy coverage for every manifest change:

```yaml
name: Admission Controller Policy Check

on:
  pull_request:
    paths:
      - "k8s/**"
      - "policies/**"

jobs:
  test-policies:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install conftest
        run: |
          wget -q https://github.com/open-policy-agent/conftest/releases/latest/download/conftest_Linux_x86_64.tar.gz
          tar xzf conftest_Linux_x86_64.tar.gz
          sudo mv conftest /usr/local/bin/

      - name: Test OPA policies against manifests
        run: conftest test k8s/ --policy policies/opa/ --all-namespaces

      - name: Verify webhook failurePolicy is Fail
        run: |
          for f in $(find . -name "*.yaml" -o -name "*.yml"); do
            if grep -q "ValidatingWebhookConfiguration\|MutatingWebhookConfiguration" "$f" 2>/dev/null; then
              if grep -q "failurePolicy: Ignore" "$f"; then
                echo "::error file=$f::failurePolicy: Ignore allows bypass. Use Fail."
                exit 1
              fi
            fi
          done
```

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Impair Defenses: Disable or Modify Tools** | [T1562.001](https://attack.mitre.org/techniques/T1562/001/) | Bypassing admission controllers disables primary policy enforcement |
| **Deploy Container** | [T1610](https://attack.mitre.org/techniques/T1610/) | Privileged containers via exempt namespaces or uncovered CRDs |
| **Exploitation for Privilege Escalation** | [T1068](https://attack.mitre.org/techniques/T1068/) | Post-admission mutations escalate workload privileges |

**Alerts:** "Pod created in kube-system by non-system account" (audit log), "Admission webhook returning errors" (API server metrics), "Gatekeeper audit violation: privileged container detected" (policy engine).

**Triage steps:**

1. Check audit log for resource creation in exempt namespaces by unexpected service accounts
2. Review Gatekeeper/Kyverno audit results (not just admission results)
3. List all pods with `privileged: true` or `hostNetwork: true` across all namespaces
4. Compare webhook `rules.resources` against all CRDs in the cluster
5. If confirmed: check what the workload accessed (tokens, secrets, host filesystem)

---

## What You Learned

- **Namespace exemptions are the most common bypass.** System namespaces excluded by default give attackers a safe harbor. Minimize exemptions; use targeted exceptions.
- **CRD coverage gaps are invisible.** Webhooks matching only Pods/Deployments miss custom workload types entirely. Use `resources: ["*"]`.
- **Post-admission mutations evade all admission control.** Webhooks fire on CREATE/UPDATE only. Gatekeeper audit mode catches drift.

## Further Reading

- [Kubernetes: Admission Controllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)
- [OPA Gatekeeper: Policy Library](https://open-policy-agent.github.io/gatekeeper-library/website/)
- [Kyverno: Policy Reference](https://kyverno.io/policies/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
