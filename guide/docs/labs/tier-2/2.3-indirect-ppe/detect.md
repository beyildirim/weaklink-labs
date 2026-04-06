# Lab 2.3: Indirect Poisoned Pipeline Execution

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

## Catching Indirect PPE

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Compromise Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Attacker modifies build scripts referenced by CI to inject malicious steps |
| **Command and Scripting Interpreter: Unix Shell** | [T1059.004](https://attack.mitre.org/techniques/T1059/004/) | Malicious shell commands injected via Makefile or build scripts |

Indirect PPE is harder to detect than Direct PPE because the CI config diff is clean. Detection must focus on files that CI executes.

Look for PRs that modify files referenced by CI (Makefile, scripts/, test configs) while NOT modifying the CI config. Watch for new `curl`, `wget`, `nc`, `base64`, or `env` commands in Makefiles or build scripts, network connections from make/test steps, and checksum mismatches in CI integrity verification.

---

**Alerts you will see:**

- "Makefile modified with network commands in PR" (git diff analysis)
- "CI checksum verification failed" (build log monitoring)
- "Outbound HTTP from build step to unfamiliar host" (network monitoring)

**Triage workflow:**

1. **Map the CI execution chain**. identify every file the CI config references
2. **Check the PR diff**. were any referenced files modified?
3. **Inspect the modifications**. network commands, file writes to /tmp, environment variable access?
4. **Check build logs**. unexpected outbound connections?
5. **If confirmed: rotate secrets**. any secret in scope during the build is compromised

**False positive rate:** Medium. Developers legitimately modify Makefiles. The key signal is the combination of modifying CI-referenced files + adding network/env commands + PR from external contributor.

---

## CI Integration

**`.github/workflows/indirect-ppe-check.yml`:**

```yaml
name: Indirect PPE Prevention

on:
  pull_request:
    paths:
      - "Makefile"
      - "scripts/**"
      - "Dockerfile*"
      - "*.sh"

jobs:
  check-referenced-files:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Scan for suspicious commands in CI-referenced files
        run: |
          echo "--- Scanning files referenced by CI for suspicious commands ---"
          SUSPICIOUS=0

          for f in Makefile scripts/*.sh Dockerfile*; do
            [ -f "$f" ] || continue

            DIFF=$(git diff origin/main...HEAD -- "$f" || true)
            if echo "$DIFF" | grep -qE '^\+.*(curl|wget|nc |ncat|python -c|base64|/tmp/|env\b)'; then
              echo "::warning file=$f::Suspicious command added to CI-referenced file"
              echo "$DIFF" | grep -E '^\+.*(curl|wget|nc |ncat|python -c|base64|/tmp/|env\b)'
              SUSPICIOUS=$((SUSPICIOUS + 1))
            fi
          done

          if [ "$SUSPICIOUS" -gt 0 ]; then
            echo "::error::$SUSPICIOUS CI-referenced file(s) have suspicious changes."
            exit 1
          fi
          echo "PASS: No suspicious changes in CI-referenced files."
```

---

## What You Learned

1. **Protecting CI configs is not enough**. Indirect PPE attacks the files CI executes, not the config itself.
2. **Hash-based integrity verification catches modifications** to Makefiles, scripts, and Dockerfiles.
3. **The PR diff hides the attack**. CI config is untouched, so reviewers miss malicious changes in build files.

## Further Reading

- [Cider Security: Indirect Poisoned Pipeline Execution](https://www.cidersecurity.io/blog/research/ppe-poisoned-pipeline-execution/)
- [Aqua Security: CI/CD Pipeline Attacks](https://blog.aquasec.com/github-actions-security-ci-cd)
- [OWASP Top 10 CI/CD: Poisoned Pipeline Execution](https://owasp.org/www-project-top-10-ci-cd-security-risks/)
