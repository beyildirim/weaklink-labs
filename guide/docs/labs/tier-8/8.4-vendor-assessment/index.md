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
