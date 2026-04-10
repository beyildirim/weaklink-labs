# Lab 2.2: Direct Poisoned Pipeline Execution (PPE)

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

## CI Configs Are Code

### Step 1: Examine the CI configuration

```bash
cd /repos/wl-webapp
cat .gitea/workflows/ci.yml
```

### Step 2: Understand the trigger model

The pipeline triggers on `push` and `pull_request` to `main`. When a PR is opened:

1. The CI system checks out the PR branch
2. It reads the CI config **from the PR branch** (not from main)
3. It executes whatever that config says

### Step 3: Check what secrets exist

```bash
curl -sf "http://gitea:3000/api/v1/repos/weaklink/wl-webapp/actions/secrets" \
  -u "weaklink:weaklink" | python -m json.tool
```

The pipeline has access to `DEPLOY_TOKEN`.

### Step 4: See the vulnerability

The CI config runs on PRs AND has secrets in scope. A PR author can modify the CI config, add a step that reads secrets, and the pipeline runs the modified config. Secrets exfiltrated.
