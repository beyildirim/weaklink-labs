# Lab 7.3: Incident Response Playbook

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

**Goal:** Learn the IR lifecycle phases as they apply to supply chain compromises.

## Step 1: The IR lifecycle

NIST SP 800-61 Rev. 2 defines six phases. See the [full document](https://csrc.nist.gov/publications/detail/sp/800-61/rev-2/final) for details.

```
┌─────────────┐    ┌─────────────┐    ┌──────────────┐
│ PREPARATION │───>│  DETECTION  │───>│ CONTAINMENT  │
│             │    │  & ANALYSIS │    │              │
└─────────────┘    └─────────────┘    └──────┬───────┘
                                             │
┌─────────────┐    ┌─────────────┐    ┌──────▼───────┐
│   LESSONS   │<───│  RECOVERY   │<───│ ERADICATION  │
│   LEARNED   │    │             │    │              │
└─────────────┘    └─────────────┘    └──────────────┘
```

## Step 2: Supply chain-specific considerations

| Phase | Supply Chain IR Specifics |
|-------|--------------------------|
| **Preparation** | Package manager hardening, CI secrets inventory, artifact signing |
| **Detection** | Proxy logs showing public registry fetches for internal names, EDR process trees from pip/npm |
| **Containment** | Quarantine CI runners, block malicious package, halt deployments |
| **Eradication** | Remove compromised packages, fix pip/npm config, rotate ALL exposed secrets |
| **Recovery** | Rebuild artifacts from verified source, redeploy, verify integrity |
| **Lessons Learned** | Update detection rules, harden CI config, implement provenance |

## Step 3: Decision tree for supply chain incidents

```
Alert: Suspicious package activity detected
│
├─ Is the package name in our internal namespace?
│  ├─ YES → Was it fetched from a public registry?
│  │        ├─ YES → CONFIRMED dependency confusion. SEV-1. Go to Containment.
│  │        └─ NO  → Verify registry source. Likely false positive.
│  └─ NO  → Is the package name a known typosquat?
│           ├─ YES → CONFIRMED typosquatting. SEV-2. Go to Containment.
│           └─ NO  → Is setup.py spawning suspicious processes?
│                    ├─ YES → PROBABLE malicious package. SEV-2. Investigate.
│                    └─ NO  → Log and monitor. Close as informational.
```
