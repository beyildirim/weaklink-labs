# Lab 2.6: GitHub Actions Injection

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

## Catching Expression Injection

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Command and Scripting Interpreter** | [T1059](https://attack.mitre.org/techniques/T1059/) | Shell command injection via expression interpolation |
| **Exploit Public-Facing Application** | [T1190](https://attack.mitre.org/techniques/T1190/) | Exploiting CI input handling through public issue/PR interfaces |

Injection payloads live in event metadata, not code changes. Look for issue or PR titles containing shell metacharacters (`` ` ``, `$(`, `&&`, `||`, `;`, `|`), workflow runs triggered by `issues.opened` or `issue_comment.created` that make outbound network connections, build logs showing unexpected command output, issues from new accounts with suspicious titles, and workflow failures with shell syntax errors (sign of a failed injection attempt).

---

**Alerts you will see:**

- "Issue title contains shell metacharacters" (webhook monitoring)
- "Outbound HTTP from issue-triggered workflow" (network monitoring)
- "Workflow step produced unexpected command output" (CI audit logs)

**Triage workflow:**

1. **Inspect the event payload**. check issue title, body, PR branch name, or comment body for shell metacharacters
2. **Check the workflow definition**. does it use `${{ github.event.* }}` directly in `run:` blocks?
3. **Review build logs**. unexpected command output or outbound connections?
4. **Check secret access**. did the workflow have access to secrets? Were they exposed?
5. **If confirmed: rotate secrets accessible to the workflow**
6. **Fix the workflow**. replace direct interpolation with `env:` variable assignment

**False positive rate:** Medium. Legitimate titles may contain `$` or `&`. Focus on complete injection patterns like `$()`, backtick pairs, or `&&`/`||` chains.

---

## CI Integration

**`.github/workflows/injection-scanner.yml`:**

```yaml
name: Actions Injection Scanner

on:
  pull_request:
    paths:
      - ".github/workflows/**"

jobs:
  scan-for-injection:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check for direct expression interpolation
        run: |
          echo "Scanning workflows for expression injection..."
          VULNERABLE=0

          for wf in .github/workflows/*.yml; do
            if grep -Pzo '(?s)run:.*?\$\{\{.*?github\.event\.(issue|pull_request|comment|discussion|head_ref|commits)' "$wf" 2>/dev/null; then
              echo "::error file=$wf::Direct interpolation of user-controlled event data in run: block"
              VULNERABLE=1
            fi
          done

          if [ "$VULNERABLE" -eq 1 ]; then
            echo "Fix: Use env: to assign expressions to environment variables"
            exit 1
          fi

          echo "No injection vulnerabilities found."

      - name: Run Zizmor (optional)
        if: always()
        run: |
          pip install zizmor 2>/dev/null && \
          zizmor .github/workflows/ || true
```

---

## What You Learned

1. **`${{ }}` expressions are interpolated before the shell runs**. user-controlled event data (issue titles, PR bodies, branch names) can contain shell metacharacters.
2. **The fix is simple: use `env:` variables**. assign the expression to an env var, then reference `$VAR` in the shell.
3. **CODEOWNERS does not help**. no files are changed. Any user who can open an issue can attack.

## Further Reading

- [GitHub Security Lab: Expression injection in Actions](https://securitylab.github.com/research/github-actions-untrusted-input/)
- [GitHub: Security hardening. using expressions](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions#understanding-the-risk-of-script-injections)
- [Zizmor: GitHub Actions static analysis](https://github.com/woodruffw/zizmor)
