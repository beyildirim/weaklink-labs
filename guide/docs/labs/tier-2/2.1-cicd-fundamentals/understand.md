# Lab 2.1: CI/CD Fundamentals

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

## What is a CI/CD Pipeline?

### Step 1: Clone the repository

```bash
cd /repos/wl-webapp
ls -la
```

### Step 2: Explore the application

```bash
cat app.py
cat requirements.txt
cat test_app.py
```

### Step 3: Examine the CI configuration

```bash
cat .gitea/workflows/ci.yml
```

Notice:

- **Triggers**: `on: push` and `on: pull_request`. the pipeline runs on every code change
- **Jobs**: `test`, `build`, `deploy`. three stages in sequence
- **Secrets**: `SECRET_TOKEN`, `DEPLOY_TOKEN`, `AWS_ACCESS_KEY_ID`. injected as environment variables

### Step 4: Identify the problem

Look at the `env:` block at the top:

```yaml
env:
  SECRET_TOKEN: ${{ secrets.SECRET_TOKEN }}
  DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
```

These secrets are available to **every job and every step**. The test job does not need deployment credentials, but it has access to them.

### Step 5: See what a pipeline run looks like

```bash
# Simulate what CI executes for the test job
echo "=== CI Test Job ==="
echo "SECRET_TOKEN=${SECRET_TOKEN:-[set by CI]}"
echo "DEPLOY_TOKEN=${DEPLOY_TOKEN:-[set by CI]}"
python test_app.py
```
