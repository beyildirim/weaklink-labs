# Lab 9.2: Serverless Supply Chain

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

**Goal:** Execute both attacks and understand their impact.

## Attack 1: Malicious Lambda Layer

```bash
cat malicious-layer/python/sitecustomize.py
```

The `sitecustomize.py` monkey-patches `__import__`, wraps the handler function, and exfiltrates every event to the attacker's C2 endpoint. The original handler runs normally. No errors, correct responses.

**What gets exfiltrated:** Every event (order IDs, API keys, customer PII, payment tokens) plus all environment variables on cold start.

## Attack 2: Dependency confusion in the build pipeline

`sam build` runs `pip install wl-order-utils>=1.0.0`. Public PyPI has version `99.0.0`. The attacker's malicious package wins resolution and gets bundled into the Lambda deployment package.

## Combined impact

1. Layer: Every invocation's event data exfiltrated
2. Dependency confusion: Build-time credentials stolen, malicious code in deployment package
3. Overprivileged IAM: `s3:*` and `dynamodb:*` give access to every bucket and table
4. No VPC isolation: Exfiltration is trivial over the internet

---

!!! success "Checkpoint"
    You should understand both attack vectors (layer interception and dependency confusion) and their combined blast radius. The layer attack is particularly dangerous because it is invisible: the function works correctly while exfiltrating every event.
