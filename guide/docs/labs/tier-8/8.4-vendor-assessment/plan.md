# Lab 8.4: Vendor Supply Chain Assessment

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../assess/" class="phase-step done">Assess</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Plan</span>
  <span class="phase-arrow">›</span>
  <a href="../document/" class="phase-step upcoming">Document</a>
</div>

**Goal:** Interpret scores, identify critical risks, determine risk tier.

## Risk tier classification

| Score | Tier | Recommendation |
|:-----:|:----:|---------------|
| 80-100% | **Low Risk** | Approve. Standard monitoring. |
| 60-79% | **Medium Risk** | Approve with conditions. Require remediation plan. |
| 40-59% | **High Risk** | CISO risk acceptance required. Increased monitoring. |
| <40% | **Critical Risk** | Do not approve. Seek alternatives. |

## Critical findings (blockers regardless of overall score)

| Finding | Impact |
|---------|--------|
| No artifact signing or provenance | Cannot verify integrity of any release |
| No vulnerability disclosure policy | No external reporting channel |
| Average patch time >30 days for critical CVEs | Unacceptable exposure window |
