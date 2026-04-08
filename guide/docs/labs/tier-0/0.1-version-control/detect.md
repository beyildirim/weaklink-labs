# Lab 0.1: How Version Control Works

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

## Spotting Malicious Commits in the Wild

What to look for:

- Direct pushes to protected branches bypassing PR workflow
- Commits modifying CI/CD files (`build.sh`, `.github/workflows/`, `Jenkinsfile`, `Makefile`)
- Outbound HTTP/DNS requests during build steps (curl, wget, nc)
- Build scripts writing to `/tmp/` or accessing environment variables containing secrets
- Force pushes that rewrite history

### MITRE ATT&CK Mapping

| Technique | ID | What to Monitor |
|-----------|----|-----------------|
| Compromise Software Supply Chain | T1195.002 | Direct pushes, CI file changes, unsigned commits |
| Unix Shell | T1059.004 | Unexpected child processes of build scripts |
| Automated Exfiltration | T1020 | Outbound connections during build, writes to /tmp |

---

### SOC Alert Rules

When you see **"Direct push to protected branch"** or **"CI build process spawned unexpected child process"** in your SIEM: someone pushed code directly to main, bypassing PR review. The malicious code executed during the next CI build. Investigate the commit diff immediately for changes to build scripts, CI configs, and lines referencing environment variables or network calls.

### CI Integration

Add this GitHub Actions workflow to enforce branch protection checks programmatically. Save as `.github/workflows/branch-protection-check.yml`:

```yaml
name: Branch Protection Enforcement

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

permissions:
  contents: read
  pull-requests: read

jobs:
  enforce-pr-review:
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    steps:
      - name: Block direct pushes to main
        run: |
          echo "::error::Direct pushes to main are not allowed."
          echo "All changes must go through a reviewed pull request."
          exit 1

  pr-checks:
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v4

      - name: Verify PR has required approvals
        uses: actions/github-script@v7
        with:
          script: |
            const reviews = await github.rest.pulls.listReviews({
              owner: context.repo.owner,
              repo: context.repo.repo,
              pull_number: context.issue.number,
            });
            const approvals = reviews.data.filter(r => r.state === 'APPROVED');
            if (approvals.length < 1) {
              core.setFailed('At least 1 approving review is required before merge.');
            }

      - name: Check for sensitive file changes
        run: |
          SENSITIVE_FILES=$(git diff --name-only origin/main...HEAD | \
            grep -E '(build\.sh|Makefile|Jenkinsfile|\.github/workflows/|\.gitlab-ci)' || true)
          if [ -n "$SENSITIVE_FILES" ]; then
            echo "::warning::This PR modifies CI/build files -- requires extra scrutiny:"
            echo "$SENSITIVE_FILES"
          fi
```

---

## What You Learned

- **Direct pushes bypass review.** Without branch protection, anyone with write access can push malicious code undetected.
- **Commit messages can lie.** A commit saying "minor cleanup" can contain a backdoor. Diffs are the only truth.
- **Branch protection forces review.** Requiring PR approvals adds a human checkpoint before code enters the main branch.

## Further Reading

- [Git Basics (git-scm.com)](https://git-scm.com/book/en/v2/Getting-Started-Git-Basics)
- [GitHub Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-a-branch-protection-rule)
- [OWASP Top 10 CI/CD: Insufficient Flow Control](https://owasp.org/www-project-top-10-ci-cd-security-risks/CICD-SEC-06-Insufficient-Credential-Hygiene)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
