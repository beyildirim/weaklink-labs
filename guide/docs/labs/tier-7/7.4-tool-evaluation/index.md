# Lab 7.4: Supply Chain Security Tool Evaluation

<div class="lab-meta">
  <span>Phase 1 ~10 min | Phase 2 ~15 min | Phase 3 ~10 min | Phase 4 ~5 min</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: <a href="../../tier-1/1.1-dependency-resolution/">Lab 1.1</a></span>
</div>

<div class="phase-stepper">
  <span class="phase-step current">Overview</span>
  <span class="phase-arrow">›</span>
  <a href="understand/" class="phase-step upcoming">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="investigate/" class="phase-step upcoming">Investigate</a>
  <span class="phase-arrow">›</span>
  <a href="validate/" class="phase-step upcoming">Validate</a>
  <span class="phase-arrow">›</span>
  <a href="improve/" class="phase-step upcoming">Improve</a>
</div>

The supply chain security tooling market has exploded. Which tools actually catch the attacks you practiced in Tier 1? Run every major tool against the same target project, then build a comparison matrix showing coverage, gaps, and cost.

### Attack Flow

```mermaid
graph LR
    A[Target<br>application] --> B[Run Tool A<br>vuln scanner]
    B --> C[Run Tool B<br>behavioral analysis]
    C --> D[Run Tool C<br>health scoring]
    D --> E[Compare<br>findings]
    E --> F[Identify<br>coverage gaps]
```
