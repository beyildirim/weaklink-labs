# Lab 8.6: OWASP SCVS Framework Assessment

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

**Goal:** Prioritized roadmap with framework overlap analysis.

## Framework overlap analysis

Controls satisfying multiple frameworks give the highest compliance ROI:

| Action | SCVS | SLSA | SSDF | EO 14028 |
|--------|:----:|:----:|:----:|:--------:|
| Fix `--extra-index-url` to `--index-url` | V4 | - | PW.4.4 | - |
| Deploy Grype in CI | V5 | - | PW.7.2 | Required |
| Generate CycloneDX SBOMs | V1, V2 | - | RV.3.3 | Required |
| Add SLSA provenance | V3, V6 | L1-L3 | PS.3.1 | - |
| Sign artifacts with cosign | V3, V6 | L2 | PS.3.1 | - |
| Define vulnerability SLAs | V5 | - | RV.3.4 | Required |

## Phased roadmap

**Phase 1. Quick wins (Days 1-14):**

| # | Action | SCVS Controls | Also Satisfies |
|:-:|--------|--------------|----------------|
| 1 | Fix namespace separation (`--index-url`) | V4.1.4 | SSDF PW.4.4 |
| 2 | Add `--require-hashes` | V4.2.1 | SSDF PW.4.4 |
| 3 | Deploy Grype in CI | V5.1.2 | SSDF PW.7.2, EO 14028 |
| 4 | Enable Dependabot on all repos | V5.1.3 | - |

**Phase 2. Foundation (Days 14-60):**

| # | Action | SCVS Controls | Also Satisfies |
|:-:|--------|--------------|----------------|
| 5 | Generate CycloneDX SBOMs in CI | V1.2.4, V2.1.1+ | SSDF RV.3.3, EO 14028 |
| 6 | Sign container images with cosign | V3.2.2, V6.2.1 | SLSA L2, SSDF PS.3.1 |
| 7 | Pin GitHub Actions to commit SHAs | V3.2.3 | SLSA L3 prep |
| 8 | Publish vulnerability remediation SLAs | V5.2.2 | SSDF RV.3.4, EO 14028 |

**Phase 3. Maturity (Days 60-180):**

| # | Action | SCVS Controls | Also Satisfies |
|:-:|--------|--------------|----------------|
| 9 | Implement SLSA Level 2 provenance | V3.2.2, V6.2.2 | SLSA L2, SSDF PS.3.1 |
| 10 | Deploy admission controller for image signatures | V6.3.2 | SLSA verification |
| 11 | Integrate OpenSSF Scorecard for upstream health | V6.2.3 | - |
