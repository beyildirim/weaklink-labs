# Lab 7.4: Supply Chain Security Tool Evaluation

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Investigate</span>
  <span class="phase-arrow">›</span>
  <a href="../validate/" class="phase-step upcoming">Validate</a>
  <span class="phase-arrow">›</span>
  <a href="../improve/" class="phase-step upcoming">Improve</a>
</div>

**Goal:** Run every tool against the same target project and record findings and misses.

## Step 1: Set up the target project

```bash
ls /app/
# requirements.txt    -- contains dependency confusion risk (extra-index-url)
# package.json        -- contains typosquat dependency
# package-lock.json   -- contains injected lockfile entry
# Dockerfile          -- builds the application
```

## Step 2: Run vulnerability scanners

**pip-audit:**
```bash
cd /app
pip-audit -r requirements.txt --output-format json 2>&1 | head -50
```

**npm audit:**
```bash
cd /app
npm audit --json 2>&1 | head -50
```

**Grype:**
```bash
grype dir:/app --output table
```

**Trivy:**
```bash
trivy fs /app --security-checks vuln,secret,config --format table
```

## Step 3: Run behavioral analysis (Socket)

Key questions: Did it flag the typosquat? The install script? The lockfile injection?

## Step 4: Run project health scoring (OpenSSF Scorecard)

```bash
scorecard --local /app --format json 2>&1 | python3 -m json.tool | head -80
```

Key checks: `Pinned-Dependencies`, `Branch-Protection`, `Code-Review`, `Dangerous-Workflow`.

## Step 5: Query dependency intelligence (deps.dev)

```bash
curl -s "https://api.deps.dev/v3alpha/systems/pypi/packages/reqeusts" | python3 -m json.tool
```

Does deps.dev distinguish the typosquat from the real package?

---

???+ success "Checkpoint"
    You should have findings from at least 4 tools (pip-audit, npm audit, Grype/Trivy, Scorecard). Note which Tier 1 attacks each tool caught and which it missed.
