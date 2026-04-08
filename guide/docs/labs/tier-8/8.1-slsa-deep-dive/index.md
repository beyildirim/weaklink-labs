# Lab 8.1: SLSA Framework Deep Dive

<div class="lab-meta">
  <span>Understand: ~10 min | Assess: ~10 min | Plan: ~15 min | Document: ~5 min</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: <a href="../../tier-4/4.4-attestation-slsa.md">Lab 4.4</a></span>
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

In [Lab 4.4](../../tier-4/4.4-attestation-slsa.md), you generated and verified SLSA provenance. This lab goes deeper: assess a real project against SLSA requirements, create a concrete action plan to reach Level 3, and produce a self-assessment for auditors.

**Reference:** [SLSA v1.0 Specification](https://slsa.dev/spec/v1.0/)

### Attack Flow

```mermaid
graph LR
    A[Source code<br>committed] --> B[Build runs on<br>hosted service]
    B --> C[Provenance<br>generated]
    C --> D[Artifact signed<br>and verified]
    D --> E[Deploy with<br>policy enforcement]
```
