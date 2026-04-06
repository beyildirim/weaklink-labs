# Lab 7.2: Supply Chain Incident Triage

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

**Goal:** Determine every pipeline, secret, artifact, and environment exposed during the compromise window.

## Step 1: Identify all affected pipelines

Query the proxy logs to find every CI runner that downloaded the malicious package. The alert told you the package name and the time window. Find all matching entries:

```bash
cat /app/logs/proxy.log | grep "internal-utils"
```

Build a table of your findings:

| CI Runner | First Seen | Last Seen | Pipeline |
|-----------|-----------|-----------|----------|
| ? | ? | ? | ? |
| ? | ? | ? | ? |

How many pipelines are affected? What is the full compromise window?

## Step 2: Determine what the malicious package does

Download and inspect the malicious package without executing it:

```bash
pip download internal-utils==99.0.0 --no-deps --no-build-isolation -d /tmp/analysis/
cd /tmp/analysis/
tar xzf internal_utils-99.0.0.tar.gz
cat internal_utils-99.0.0/setup.py
```

Read the `setup.py` carefully. Answer these questions:

1. What data does it collect?
2. Where does it send the data?
3. What environment variable patterns does it target?

## Step 3: Identify exposed secrets

Based on what you learned from `setup.py`, determine which environment variables would match the exfiltration filter. Query the CI configuration for each affected pipeline:

```bash
cat /app/ci-config/build-api-service.yml | grep -E "env:|secret"
cat /app/ci-config/build-payment-service.yml | grep -E "env:|secret"
cat /app/ci-config/build-auth-service.yml | grep -E "env:|secret"
```

Build a table of exposed secrets per pipeline:

| Pipeline | Exposed Secrets |
|----------|----------------|
| ? | ? |
| ? | ? |

## Step 4: Identify artifacts built during the window

Check the registry logs for any images pushed during the compromise window:

```bash
cat /app/logs/registry.log | grep -E "push.*v[0-9]" | awk '$0 >= "11:43" && $0 <= "14:47"'
```

List each affected artifact with its tag and push timestamp.

## Step 5: Check for deployment to production

```bash
cat /app/logs/deploy.log | grep "production"
```

Were any of the compromised artifacts deployed to production? If so, which ones and when?

---

!!! success "Checkpoint"
    You should now have a complete blast radius picture covering: affected runners, affected pipelines, exfiltrated secrets, compromised artifacts, and any production deployments. If any scope element is missing, query the corresponding log source before continuing.
