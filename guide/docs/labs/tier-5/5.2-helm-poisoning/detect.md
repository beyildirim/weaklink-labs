# Lab 5.2: Helm Chart Poisoning

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

## Finding Poisoned Charts in Production

Chart poisoning is stealthy: the hook Job runs, succeeds, and deletes itself. Detection relies on **Kubernetes audit logs** (RBAC changes) and **admission controller logs** (policy violations).

**Key indicators:**

- ClusterRoleBinding creation referencing `cluster-admin` outside expected system operations
- Jobs with `helm.sh/hook` annotations creating RBAC resources
- ClusterRoleBindings referencing the `default` service account (almost never legitimate)
- Hook Jobs making network calls to external endpoints

| Indicator | What It Means |
|-----------|---------------|
| K8s API calls creating ClusterRoleBindings from a Job pod | Hook is modifying RBAC |
| HTTP POST from a pod with `helm.sh/hook` label to external IP | Hook is exfiltrating data |
| `kubectl` binary execution inside a container | Hook running privilege escalation commands |

### CI Integration

Scan rendered Helm manifests in every PR:

```yaml
name: Helm Chart Security Scan

on:
  pull_request:
    paths:
      - "**/templates/**"
      - "**/Chart.yaml"

jobs:
  scan-hooks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Helm
        uses: azure/setup-helm@v4
      - name: Scan for dangerous Helm hooks
        run: |
          FOUND=0
          for chart_dir in $(find . -name "Chart.yaml" -exec dirname {} \;); do
            RENDERED=$(helm template scan-check "$chart_dir" 2>/dev/null || true)
            if echo "$RENDERED" | grep -A10 'kind: ClusterRoleBinding' | grep -q 'cluster-admin'; then
              echo "::error::CRITICAL: $chart_dir creates ClusterRoleBinding with cluster-admin"
              FOUND=1
            fi
            if echo "$RENDERED" | grep -A30 'helm.sh/hook' | grep -qE '(curl|wget|nc |kubectl)'; then
              echo "::error::CRITICAL: $chart_dir has hooks running network/kubectl commands"
              FOUND=1
            fi
          done
          [ "$FOUND" -eq 0 ] || exit 1
```

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Compromise Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Attacker modifies Helm chart to include malicious hooks |
| **Valid Accounts: Default Accounts** | [T1078](https://attack.mitre.org/techniques/T1078/) | Backdoor grants cluster-admin to the `default` service account |

**Alerts:** "ClusterRoleBinding created granting cluster-admin" (K8s audit logs), "Helm hook Job created ClusterRoleBinding" (admission controller), "Short-lived Job pod in default namespace" (pod inventory).

**Triage workflow:**

1. **Check the ClusterRoleBinding.** If it grants access to the `default` service account, this is almost certainly malicious.
2. **Trace the creator.** Which service account created it? If a Helm hook Job, check which chart was installed.
3. **Scope blast radius.** Any pod running as `default` in any namespace now has cluster-admin.

---

## What You Learned

- **Post-install hooks with `hook-delete-policy: hook-succeeded` are invisible.** They run, succeed, delete themselves. No trace in `helm list` or `kubectl get jobs`.
- **Chart poisoning is persistent.** A ClusterRoleBinding created by a hook survives `helm uninstall` because hooks are managed separately from release resources.
- **`helm template` is your pre-flight check.** Always render and review before installing. Admission policies (Kyverno/OPA) are the safety net.

## Further Reading

- [Helm Documentation: Chart Hooks](https://helm.sh/docs/topics/charts_hooks/)
- [Kyverno: Policy Examples](https://kyverno.io/policies/)
- [Datadog: Helm Chart Security (2023 research)](https://securitylabs.datadoghq.com/articles/helm-chart-security/)
