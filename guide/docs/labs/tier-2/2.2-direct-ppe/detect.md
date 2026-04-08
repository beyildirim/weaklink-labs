# Lab 2.2: Direct Poisoned Pipeline Execution (PPE)

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

## Catching Pipeline Poisoning

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Compromise Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Attacker modifies CI pipeline definition to inject malicious build steps |
| **Command and Scripting Interpreter** | [T1059](https://attack.mitre.org/techniques/T1059/) | Malicious CI steps execute shell commands to exfiltrate secrets |

Direct PPE has a clear signal: CI config files modified in a PR, and the pipeline immediately accesses secrets or makes external connections.

Look for commits modifying `.github/workflows/`, `.gitlab-ci.yml`, or `Jenkinsfile` in PR branches. Watch for PR builds that access secrets not historically used, outbound network connections from PR-triggered builds, CI config changes adding `curl`/`wget`/`nc`/`env` commands, and PRs from new or external contributors that touch CI configs.

---

**Alerts you will see:**

- "CI config modified in pull request" (git webhook monitoring)
- "PR build accessed production secrets" (CI audit logs)
- "Outbound HTTP from PR-triggered build to external host" (network monitoring)

**Triage workflow:**

1. **Check the PR diff**. does it modify CI config files? What was added?
2. **Check for exfiltration indicators**. curl, wget, nc, base64, or DNS queries in modified CI steps
3. **Check secret access logs**. did the PR build access secrets it should not have?
4. **Check the PR author**. known contributor or new/external account?
5. **If confirmed: rotate secrets immediately**. any secret accessible to the PR build is compromised

**False positive rate:** Low. CI config modifications in PRs from external contributors are inherently suspicious.

---

## CI Integration

**`.github/workflows/ppe-prevention.yml`:**

```yaml
name: PPE Prevention Check

on:
  pull_request:
    paths:
      - ".github/workflows/**"

jobs:
  check-workflow-changes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Flag workflow file changes
        run: |
          echo "--- CI config files modified in this PR ---"
          CHANGED=$(git diff --name-only origin/main...HEAD -- \
            '.github/workflows/' '.gitea/workflows/' \
            '.gitlab-ci.yml' 'Jenkinsfile')
          if [ -n "$CHANGED" ]; then
            echo "::warning::CI pipeline configs modified in this PR:"
            echo "$CHANGED"
            echo ""
            echo "These changes require CODEOWNERS approval."
            echo "Reviewer: verify no secret exfiltration, no curl/wget"
            echo "to external hosts, no env/printenv commands."
          fi
```

---

## What You Learned

1. **PRs can modify CI configs**. the pipeline runs the PR's version, not main's version. Direct PPE is trivial.
2. **Separate push and PR workflows**. secrets only on push to protected branches, never on PRs.
3. **CODEOWNERS for CI configs**. require admin review for any workflow changes.

## Further Reading

- [Cider Security: Poisoned Pipeline Execution](https://www.cidersecurity.io/blog/research/ppe-poisoned-pipeline-execution/)
- [GitHub: Security hardening. using secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions)
- [OWASP: CI/CD Security Risks - PPE](https://owasp.org/www-project-top-10-ci-cd-security-risks/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
