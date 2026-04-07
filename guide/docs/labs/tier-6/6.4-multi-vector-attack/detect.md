# Lab 6.4: Multi-Vector Chained Attack

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

## Detecting Multi-Stage Kill Chains

No single signal is conclusive. The key is **cross-layer correlation**: a typosquatted package install followed by a CI workflow change followed by an unexpected image push is a chain that demands investigation even if each event alone looks benign.

**Key indicators:**

- New dependency that is a near-homograph of an existing one (package layer)
- Workflow file modified in the same PR as a new dependency (CI layer)
- Container image rebuilt with a different layer hash than expected (image layer)
- Production pod making outbound connections to unfamiliar endpoints (runtime layer)

| Indicator | What It Means |
|-----------|---------------|
| Near-homograph package name in dependency diff | Potential typosquatting |
| Workflow file change correlates with new dependency PR | CI modification from package postinstall |
| Image layer hash changed without source change | Backdoor injected during build |
| Outbound connection from production pod | Post-compromise exfiltration or C2 |

### MITRE ATT&CK Mapping

| Technique | ID | Stage | Relevance |
|-----------|-----|-------|-----------|
| **Supply Chain Compromise: Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | 1, 2, 3 | End-to-end supply chain compromise |
| **Command and Scripting Interpreter: JavaScript** | [T1059.007](https://attack.mitre.org/techniques/T1059/007/) | 1 | npm postinstall script executes attacker code |
| **Modify CI/CD Pipeline** | [T1584.010](https://attack.mitre.org/techniques/T1584/010/) | 2 | Attacker modifies build pipeline |
| **Deploy Container** | [T1610](https://attack.mitre.org/techniques/T1610/) | 3 | Backdoored container image deployed to production |

**Alerts (individually, each looks low-severity):** "New npm dependency added" (package audit), "CI workflow file modified" (repo audit), "Container image layers changed" (registry audit), "Outbound connection from production pod" (network monitor).

**Why correlation matters:** Each alert alone is routine. When these events occur in sequence within a short timeframe and are linked by the same PR/commit, the combination indicates a multi-stage attack.

**Triage steps:**

1. Check if the new dependency was intentional; verify for near-homograph names
2. Review workflow changes against the dependency addition in the same PR
3. Compare image layers before and after the suspicious build
4. Check production pod network connections for unexpected endpoints
5. If confirmed: revoke all CI secrets, quarantine the image, roll back the deployment

---

### CI Integration

Add this workflow to correlate multiple supply chain signals within a single PR. Save as `.github/workflows/multi-vector-check.yml`:

```yaml
name: Multi-Vector Supply Chain Check

on:
  pull_request:

permissions:
  contents: read

jobs:
  cross-layer-correlation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Correlate supply chain signals
        run: |
          SIGNALS=0
          REPORT=""

          # Signal 1: New dependencies added
          DEP_CHANGES=$(git diff --name-only origin/main...HEAD -- \
            'package.json' 'package-lock.json' \
            'requirements*.txt' 'pyproject.toml' || true)
          if [ -n "$DEP_CHANGES" ]; then
            SIGNALS=$((SIGNALS + 1))
            REPORT="${REPORT}\n- Dependency files changed: $DEP_CHANGES"
          fi

          # Signal 2: CI/workflow files modified
          CI_CHANGES=$(git diff --name-only origin/main...HEAD -- \
            '.github/workflows/' '.gitea/workflows/' \
            'Jenkinsfile' '.gitlab-ci.yml' || true)
          if [ -n "$CI_CHANGES" ]; then
            SIGNALS=$((SIGNALS + 1))
            REPORT="${REPORT}\n- CI config files changed: $CI_CHANGES"
          fi

          # Signal 3: Dockerfile or image config modified
          IMAGE_CHANGES=$(git diff --name-only origin/main...HEAD -- \
            '**/Dockerfile*' '**/docker-compose*.yml' \
            'k8s/' 'deploy/' 'helm/' || true)
          if [ -n "$IMAGE_CHANGES" ]; then
            SIGNALS=$((SIGNALS + 1))
            REPORT="${REPORT}\n- Container/deploy files changed: $IMAGE_CHANGES"
          fi

          # Signal 4: Install scripts or post-install hooks
          SCRIPT_CHANGES=$(git diff origin/main...HEAD -- '*.py' '*.js' '*.sh' | \
            grep -c '^\+.*\(postinstall\|preinstall\|setup(\|subprocess\)' || true)
          if [ "$SCRIPT_CHANGES" -gt 0 ]; then
            SIGNALS=$((SIGNALS + 1))
            REPORT="${REPORT}\n- Install script patterns detected in diff"
          fi

          echo "Supply chain signals detected: $SIGNALS"
          if [ "$SIGNALS" -ge 3 ]; then
            echo "::error::MULTI-VECTOR ALERT: $SIGNALS supply chain layers modified in a single PR."
            echo -e "Signals found:$REPORT"
            echo ""
            echo "This combination requires manual security review."
            exit 1
          elif [ "$SIGNALS" -ge 2 ]; then
            echo "::warning::$SIGNALS supply chain layers modified. Review carefully."
            echo -e "Signals found:$REPORT"
          else
            echo "PASS: No multi-vector pattern detected."
          fi
```

---

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

---

## What You Learned

- **Real attacks chain multiple techniques.** Typosquatting, CI poisoning, and image tampering are more dangerous in combination because each stage operates in the blind spot of the previous layer's controls.
- **Cross-layer correlation is the detection key.** A new dependency plus workflow change plus image rebuild in the same PR demands investigation.
- **`ignore-scripts` breaks Stage 1.** Disabling postinstall scripts prevents the initial foothold.

## Further Reading

- [SLSA: Supply-chain Levels for Software Artifacts](https://slsa.dev/)
- [Sigstore: Cosign, Rekor, and Fulcio](https://sigstore.dev/)
- [OpenSSF: Scorecard. Automated Security Checks](https://securityscorecards.dev/)
