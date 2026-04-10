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

## Catching Exempt-Namespace Bypasses

Exempt namespaces leave a simpler signal than most webhook failures: the risky workload lands in a namespace you intentionally excluded from policy.

**Key indicators:**

- Pod creation in `monitoring` by non-system service accounts
- Privileged containers running in namespaces that appear on the exclusion list
- Drift between the documented exemption list and the live Gatekeeper/Kyverno config

| Indicator | What It Means |
|-----------|---------------|
| Privileged pod created in `monitoring` | A workload landed in a namespace the policy does not cover |
| Non-system service account creating resources in an excluded namespace | Policy-safe harbor is being used by regular workloads |
| Exclusion list growing without review | The admission boundary is weakening over time |

### CI Integration

Test policy coverage for every manifest change:

```yaml
name: Admission Controller Policy Check

on:
  pull_request:
    paths:
      - "gatekeeper-config/**"
      - "exploits/**"
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

      - name: Test policy config against forbidden namespace exemptions
        run: |
          for f in $(find gatekeeper-config policies -name "*.yaml" -o -name "*.yml" 2>/dev/null); do
            if grep -q "excludedNamespaces" "$f" 2>/dev/null; then
              if grep -q "monitoring" "$f"; then
                echo "::error file=$f::monitoring exemption reintroduced"
                exit 1
              fi
            fi
          done
```

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Deploy Container** | [T1610](https://attack.mitre.org/techniques/T1610/) | Primary. A privileged container is deployed through an exempt namespace |
| **Subvert Trust Controls** | [T1553](https://attack.mitre.org/techniques/T1553/) | Admission policy exists, but the trust boundary is weakened by exception handling |

**Alert:** "Privileged pod created in excluded namespace by non-system account"

**Triage steps:**

1. Check audit log for resource creation in excluded namespaces by unexpected service accounts
2. List all privileged pods across all excluded namespaces
3. Compare the live exclusion list to the reviewed policy baseline
4. If confirmed: inspect what the workload accessed and whether the exemption is still needed

---

## What You Learned

- **Namespace exemptions are enough to break the guarantee.** One excluded namespace can nullify an otherwise strong policy.
- **Policy exceptions deserve the same scrutiny as policy rules.** Review them, minimize them, and test them in CI.
- **A green policy dashboard can still hide risk.** If the namespace is exempt, the workload never hits the controller at all.

## Further Reading

- [Kubernetes: Admission Controllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)
- [OPA Gatekeeper: Policy Library](https://open-policy-agent.github.io/gatekeeper-library/website/)
- [Kyverno: Policy Reference](https://kyverno.io/policies/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
