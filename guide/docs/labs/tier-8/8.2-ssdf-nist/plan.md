# Lab 8.2: SSDF / NIST SP 800-218 Mapping

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

**Goal:** Phased roadmap with priorities, timelines, and owners.

## Phase 1. Quick wins (Days 1-30)

| Action | SSDF Task | Deliverable |
|--------|-----------|-------------|
| Publish vulnerability disclosure policy | RV.2.1 | SECURITY.md in all repos |
| Generate SBOMs in CI for all projects | RV.3.3 | CycloneDX SBOM per release |
| Add `--require-hashes` to Python projects | PW.4.4 | Updated requirements files |

## Phase 2. Foundation (Days 30-90)

| Action | SSDF Task | Deliverable |
|--------|-----------|-------------|
| Standardize SCA scanning in all CI | PO.3.1 | CI template with Grype/Trivy |
| Sign all container images with cosign | PS.3.1 | Signing workflow in CI |
| Define vulnerability remediation SLAs | RV.3.4 | SLA document (Critical: 48h, High: 7d, Medium: 30d) |

## Phase 3. Maturity (Days 90-180)

| Action | SSDF Task | Deliverable |
|--------|-----------|-------------|
| Implement SLSA Level 2 provenance | PS.3.1 | Provenance attestation in CI |
| Integrate threat modeling in design reviews | PW.1.1 | Threat model template + training |
| Launch developer security training | PO.2.1 | Training program |
