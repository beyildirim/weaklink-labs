# Lab 5.1: How Helm Charts Resolve Dependencies

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

## Finding Chart Hijacking in Production

Helm resolving from untrusted repos or chart versions jumping to unusual numbers (e.g., 18.6.1 to 99.0.0). Primary telemetry sources: Helm audit logs, container registry access logs, CI/CD network traffic.

**Key indicators:**

- Helm pulling charts from public repos when policy requires private only
- Chart version numbers jumping unexpectedly
- Post-install hooks creating Jobs, ClusterRoleBindings, or other security-sensitive resources
- Outbound HTTP from Helm hook Jobs to external endpoints

| Indicator | What It Means |
|-----------|---------------|
| HTTP GET to `charts.example.com` from CI runners | Charts pulled from public repo |
| HTTP POST from a K8s Job pod to external IP | Post-install hook exfiltrating data |
| OCI registry pull from `ghcr.io`/`docker.io` for chart artifacts | Charts from public OCI registry |

### CI Integration

Reject version ranges and public repositories in CI:

```yaml
name: Helm Chart Dependency Check

on:
  pull_request:
    paths:
      - "**/Chart.yaml"
      - "**/Chart.lock"

jobs:
  check-helm-deps:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Reject version ranges in Chart.yaml
        run: |
          FOUND=0
          for f in $(find . -name "Chart.yaml" -not -path "*/charts/*"); do
            if grep -E 'version:\s*"[><=~^]' "$f"; then
              echo "::error file=$f::Chart dependency uses version range. Pin to exact version."
              FOUND=1
            fi
          done
          [ "$FOUND" -eq 0 ] || exit 1

      - name: Verify Chart.lock exists and has digests
        run: |
          for chart_yaml in $(find . -name "Chart.yaml" -not -path "*/charts/*"); do
            dir=$(dirname "$chart_yaml")
            if grep -q "dependencies:" "$chart_yaml"; then
              if [ ! -f "$dir/Chart.lock" ]; then
                echo "::error file=$chart_yaml::Chart has dependencies but no Chart.lock."
                exit 1
              fi
            fi
          done
```

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Compromise Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Attacker publishes higher-version chart to hijack dependency resolution |
| **Deploy Container** | [T1610](https://attack.mitre.org/techniques/T1610/) | Malicious chart deploys attacker-controlled containers via hook Jobs |

**Alert:** "Helm chart resolved from unapproved repository" or "Unusually high chart version installed"

**Triage steps:**

1. Check which chart was pulled and from which repository
2. Compare the version against `Chart.lock` in version control
3. Render with `helm template` and look for hooks, Jobs, or RBAC resources
4. If a post-install hook exists: check for network calls or RBAC bindings
5. If confirmed malicious: check all clusters that pulled from the same repo in the same timeframe

---

## What You Learned

- **Version ranges (`>=`, `^`, `~`) let Helm pull malicious higher versions.** Chart.lock pins exact versions with SHA digests and must be committed.
- **Public Helm repos are attack surface.** Use private registries or mirror vetted charts.
- **OCI registries add integrity** through content-addressable storage, making chart substitution harder than traditional repos.

## Further Reading

- [Helm Documentation: Chart Dependencies](https://helm.sh/docs/helm/helm_dependency/)
- [Helm Documentation: Provenance and Integrity](https://helm.sh/docs/topics/provenance/)
- [Helm Documentation: OCI Registries](https://helm.sh/docs/topics/registries/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
