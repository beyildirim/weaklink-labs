# Lab 2.1: CI/CD Fundamentals

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

## Catching Secret Exposure in CI

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Compromise Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Attacker modifies CI pipeline to access deployment credentials |
| **Valid Accounts: Cloud Accounts** | [T1078.004](https://attack.mitre.org/techniques/T1078/004/) | Stolen CI secrets provide access to cloud infrastructure |

Detection focuses on two signals: CI config changes that expose secrets, and build logs containing credential patterns.

Look for build logs containing API key patterns (`AKIA`, `ghp_`, `sk-`), CI config changes adding `env | sort` / `printenv` / `set`, jobs accessing secrets they have not historically used, and PR builds that reference `secrets.*`.

Network-side, watch for outbound HTTP POST from CI runners to external URLs with Base64 bodies, DNS queries with long encoded subdomains from CI infrastructure, and CI runners connecting to unfamiliar external IPs during test jobs.

---

**Alerts you will see:**

- "Secret pattern detected in build logs" (log analysis)
- "Non-deploy job accessed production secrets" (CI audit)
- "CI config modified to expose environment variables" (git monitoring)

**Triage workflow:**

1. **Check which secrets were exposed**. review build logs for secret patterns
2. **Check who triggered the build**. PR from external contributor or known developer?
3. **Check the CI config diff**. did the pipeline config change? Was it reviewed?
4. **Rotate exposed secrets immediately**. assume any secret visible in logs is compromised
5. **Audit downstream access**. check if exposed credentials were used against production

**False positive rate:** Medium. Developers sometimes accidentally echo environment variables. The key signal is whether the build was triggered by a PR (high risk) vs. push to main (lower risk, but still bad).

---

## CI Integration

**`.github/workflows/secret-scope-check.yml`:**

```yaml
name: CI Secret Scope Audit

on:
  pull_request:
    paths:
      - ".github/workflows/**"
      - ".gitea/workflows/**"

jobs:
  audit-secrets:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check for global secret exposure
        run: |
          echo "--- Auditing CI configs for overly-broad secret scoping ---"
          ISSUES=0

          for f in .github/workflows/*.yml .gitea/workflows/*.yml; do
            [ -f "$f" ] || continue
            echo "Checking: $f"

            # Check for secrets in top-level env block
            if awk '/^env:/,/^[a-z]/' "$f" | grep -q 'secrets\.'; then
              echo "::error file=$f::CRITICAL: Secrets in global env block. Scope to specific steps."
              ISSUES=$((ISSUES + 1))
            fi

            # Check for env/printenv/set in run blocks
            if grep -E '^\s+run:.*\b(env|printenv|set)\b' "$f"; then
              echo "::warning file=$f::Potential secret leak: env/printenv/set in run block."
              ISSUES=$((ISSUES + 1))
            fi
          done

          if [ "$ISSUES" -gt 0 ]; then
            echo "Found $ISSUES issue(s). Fix before merging."
            exit 1
          fi
          echo "PASS: No secret scope issues found."
```

---

## What You Learned

1. **Global secret scoping is the default mistake**. most CI configs inject secrets at the top level, making them available to every job.
2. **Any developer with PR access can steal secrets** by modifying the CI config in a pull request.
3. **Scope secrets to only the jobs and steps that need them**. least privilege applies to CI too.

## Further Reading

- [Cider Security: Top 10 CI/CD Security Risks](https://www.cidersecurity.io/top-10-cicd-security-risks/)
- [GitHub Docs: Security hardening for GitHub Actions](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [OWASP: CI/CD Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/CI_CD_Security_Cheat_Sheet.html)
