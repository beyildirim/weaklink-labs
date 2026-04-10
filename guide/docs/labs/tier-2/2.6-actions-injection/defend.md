# Lab 2.6: GitHub Actions Injection

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Defend</span>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Safe Expression Handling

### Fix 1: Use environment variables instead of direct interpolation

```bash
cd /repos/wl-webapp
git checkout main
```

Assign the expression to an environment variable, then reference the variable in the shell. Environment variables are passed as data, not interpolated into the command string.

**Vulnerable:**

```yaml
- name: Process issue
  run: echo "Processing: ${{ github.event.issue.title }}"
```

**Fixed:**

```yaml
- name: Process issue
  env:
    ISSUE_TITLE: ${{ github.event.issue.title }}
  run: echo "Processing: $ISSUE_TITLE"
```

The malicious content is treated as a string value, not a shell command.

### Fix 2: Apply the fix to the workflow

```bash
cp /lab/src/repo/.gitea/workflows/issue-handler-safe.yml .gitea/workflows/issue-handler.yml
cp /lab/src/repo/.gitea/workflows/pr-handler-safe.yml .gitea/workflows/pr-handler.yml

cat .gitea/workflows/issue-handler.yml
cat .gitea/workflows/pr-handler.yml
```

### Fix 3: Audit all workflows for injection

```bash
grep -rn '\${{.*github\.event\.' .gitea/workflows/ | grep 'run:' || true

grep -rn '\${{.*\(issue\|pull_request\|comment\|discussion\|head_ref\|commits\)' \
  .gitea/workflows/ | grep -v 'env:' | grep -v '#' || true
```

### Fix 4: Commit and push

```bash
git add -A
git commit -m "Fix Actions injection: use env vars for all user-controlled inputs"
git push origin main
```

### Additional defenses

1. **Use `actions/github-script`** for GitHub API interactions. inputs passed as JavaScript strings, not shell commands
2. **Restrict workflow permissions** via `permissions:`
3. **Use CodeQL or Zizmor** to scan workflows for expression injection patterns
