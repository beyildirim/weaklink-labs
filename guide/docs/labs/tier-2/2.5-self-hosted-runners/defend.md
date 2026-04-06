# Lab 2.5: Self-Hosted Runner Attacks

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

## Ephemeral Runners and Isolation

### Fix 1: Use ephemeral (just-in-time) runners

```bash
cd /repos/wl-webapp
git checkout main
```

```bash
cat > /runner/config.yaml << 'EOF'
ephemeral: true
replace_existing: true

container:
  image: "ubuntu:22.04"
  options: "--rm --network=none"
  workdir: "/workspace"
EOF
```

### Fix 2: Apply workflow hardening

```bash
cat > .gitea/workflows/ci.yml << 'EOF'
name: WeakLink Webapp CI

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: self-hosted
    container:
      image: node:20-slim
      options: --rm --read-only --tmpfs /tmp
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: python test_app.py

  pr-test:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest  # Ephemeral GitHub-hosted runner for PRs
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: python test_app.py
EOF
```

### Fix 3: Add state verification between jobs

```bash
cat > /runner/hooks/pre-run.sh << 'CHECKEOF'
#!/bin/bash
EXPECTED_HASH="$(cat /runner/.state-hash 2>/dev/null)"
CURRENT_HASH="$(find /runner/_work/_tool -type f -exec sha256sum {} \; | sort | sha256sum | cut -d' ' -f1)"

if [ "$EXPECTED_HASH" != "$CURRENT_HASH" ]; then
  echo "::error::Runner state has been tampered with!"
  exit 1
fi

if crontab -l 2>/dev/null | grep -v '^#' | grep -q .; then
  echo "::error::Unexpected cron jobs detected on runner!"
  exit 1
fi

SUSPICIOUS=$(ps aux | grep -E '(curl|wget|nc|ncat)' | grep -v grep)
if [ -n "$SUSPICIOUS" ]; then
  echo "::error::Suspicious processes detected on runner!"
  exit 1
fi
CHECKEOF

chmod +x /runner/hooks/pre-run.sh
```

### Fix 4: Commit and push

```bash
git add -A
git commit -m "Harden runner: ephemeral mode, container isolation, state verification"
git push origin main
```

### Key defenses

1. **Ephemeral runners** (`--ephemeral`). runner exits after one job, no persistence
2. **Container isolation**. each job runs in a disposable container with `--rm`
3. **Never run untrusted PRs on self-hosted runners**. use GitHub-hosted for PR workflows
4. **State verification hooks**. hash the tool cache and check for tampering before each job

### Step 5: Final verification

```bash
weaklink verify 2.5
```
