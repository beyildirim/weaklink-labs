# Lab 8.6: OWASP SCVS Framework Assessment

<div class="lab-meta">
  <span>Phase 1 ~10 min | Phase 2 ~15 min | Phase 3 ~10 min | Phase 4 ~5 min</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: <a href="../8.1-slsa-deep-dive/">Lab 8.1</a>, <a href="../8.2-ssdf-nist/">Lab 8.2</a></span>
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

SCVS provides a comprehensive, granular checklist covering everything from knowing what components you have to verifying where they came from. Unlike SLSA (build integrity focus) or SSDF (organizational secure development), SCVS covers the full component lifecycle. OWASP developed SCVS in direct response to incidents like SolarWinds (2020) and Log4Shell (CVE-2021-44228), which exposed that most organizations had no systematic way to verify the components in their software.

**Reference:** [OWASP SCVS](https://owasp.org/www-project-software-component-verification-standard/)

### Attack Flow

```mermaid
graph TD
    A[V1: Inventory<br>components] --> B[V2: Generate<br>SBOM]
    B --> C[V3: Verify build<br>environment]
    C --> D[V4: Secure package<br>management]
    D --> E[V5: Analyze<br>vulnerabilities]
    E --> F[V6: Verify pedigree<br>and provenance]
```

!!! tip "Related Labs"
    - **Prerequisite:** [8.1 SLSA Framework Deep Dive](../8.1-slsa-deep-dive/index.md) — SLSA framework knowledge helps interpret SCVS controls
    - **Prerequisite:** [8.2 SSDF / NIST SP 800-218 Mapping](../8.2-ssdf-nist/index.md) — SSDF mapping provides context for SCVS assessment
    - **See also:** [8.5 Building a Supply Chain Security Program](../8.5-building-a-program/index.md) — SCVS assessment informs program building priorities
    - **See also:** [4.1 What SBOMs Actually Contain](../../tier-4/4.1-sbom-contents/index.md) — SBOM practices are heavily assessed in SCVS
