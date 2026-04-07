# Lab 8.4: Vendor Supply Chain Assessment

<div class="lab-meta">
  <span>Phase 1 ~5 min | Phase 2 ~15 min | Phase 3 ~10 min | Phase 4 ~5 min</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: <a href="../8.1-slsa-deep-dive/">Lab 8.1</a></span>
</div>

<div class="phase-stepper">
  <span class="phase-step current">Overview</span>
  <span class="phase-arrow">›</span>
  <a href="understand/" class="phase-step upcoming">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="assess/" class="phase-step upcoming">Assess</a>
  <span class="phase-arrow">›</span>
  <a href="plan/" class="phase-step upcoming">Plan</a>
  <span class="phase-arrow">›</span>
  <a href="document/" class="phase-step upcoming">Document</a>
</div>

You have secured your own supply chain. Now flip the perspective: evaluate a third-party vendor's software before purchasing or integrating it. Does the vendor sign releases? Provide SBOMs? Patch known CVEs within a week?

### Attack Flow

```mermaid
graph LR
    A[Identify vendor<br>product] --> B[Apply assessment<br>questionnaire]
    B --> C[Score across<br>5 dimensions]
    C --> D[Classify<br>risk tier]
    D --> E[Approve / reject /<br>require remediation]
```

!!! tip "Related Labs"
    - **Prerequisite:** [8.1 SLSA Framework Deep Dive](../8.1-slsa-deep-dive/index.md) — SLSA levels are a primary vendor assessment criterion
    - **Next:** [8.5 Building a Supply Chain Security Program](../8.5-building-a-program/index.md) — Vendor assessment feeds into building a full security program
    - **See also:** [8.3 Executive Order 14028 Compliance](../8.3-eo-14028/index.md) — EO 14028 mandates vendor supply chain transparency
    - **See also:** [4.1 What SBOMs Actually Contain](../../tier-4/4.1-sbom-contents/index.md) — SBOM requirements are central to vendor evaluation
