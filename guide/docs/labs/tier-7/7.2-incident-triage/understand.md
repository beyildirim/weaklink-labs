# Lab 7.2: Supply Chain Incident Triage

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../investigate/" class="phase-step upcoming">Investigate</a>
  <span class="phase-arrow">›</span>
  <a href="../validate/" class="phase-step upcoming">Validate</a>
  <span class="phase-arrow">›</span>
  <a href="../improve/" class="phase-step upcoming">Improve</a>
</div>

**Goal:** Review the alert and establish what you know before investigating.

## Step 1: Read the alert details

```
Alert ID:       WLSOC-2026-0042
Fired at:       2026-04-01 14:47:00 UTC
Rule:           Internal package fetched from public PyPI (Rule 7100001)
Severity:       Critical (auto-classified)
Source:         Proxy log (Squid)
Details:        GET https://pypi.org/packages/internal-utils/internal_utils-99.0.0.tar.gz
                Source IP: 10.100.0.17 (ci-runner-07)
                HTTP 200, 185,732 bytes downloaded
First seen:     2026-04-01 11:43:22 UTC  (3+ hours ago)
```

## Step 2: Establish the known facts

| Known | Unknown |
|-------|---------|
| `internal-utils@99.0.0` was downloaded from public PyPI | Who published the malicious package |
| The download happened on `ci-runner-07` | What the malicious package does |
| It happened 3 hours ago | How many pipelines pulled this version |
| The package name matches an internal namespace | What secrets were accessible on the CI runner |
| Version 99.0.0 is anomalously high | Whether artifacts built during the window are compromised |

## Step 3: Set investigation priorities

1. **Scope**. How widespread is the compromise?
2. **Impact**. What was exposed/exfiltrated?
3. **Containment**. How do we stop the bleeding?
4. **Classification**. What severity do we assign?
5. **Communication**. Who needs to know?
