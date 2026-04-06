# Lab 2.3: Indirect Poisoned Pipeline Execution

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

## CI References External Files

### Step 1: Examine the CI configuration

```bash
cd /repos/wl-webapp
cat .gitea/workflows/ci.yml
```

The CI config runs `make test` and `bash scripts/run-tests.sh`. The actual code lives in `Makefile` and `scripts/run-tests.sh`.

### Step 2: Examine the referenced files

```bash
cat Makefile
cat scripts/run-tests.sh
```

Normal build and test files. But NOT protected by CODEOWNERS or branch protection.

### Step 3: Map the attack surface

| File | CI Command | Protected? |
|------|-----------|------------|
| `Makefile` | `make test`, `make build` | No |
| `scripts/run-tests.sh` | `bash scripts/run-tests.sh` | No |
| `requirements.txt` | `pip install -r requirements.txt` | No |

### Step 4: Check that secrets are in scope

```bash
grep -E 'secrets\.|env:' .gitea/workflows/ci.yml
```

The test job has `DEPLOY_TOKEN` in its environment. Any code executed by `make test` can read it.
