# Lab 8.6: OWASP SCVS Framework Assessment

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../assess/" class="phase-step upcoming">Assess</a>
  <span class="phase-arrow">›</span>
  <a href="../plan/" class="phase-step upcoming">Plan</a>
  <span class="phase-arrow">›</span>
  <a href="../document/" class="phase-step upcoming">Document</a>
</div>

**Goal:** Learn the SCVS categories, maturity levels, and how SCVS complements SLSA and SSDF.

## SCVS structure

| Category | What It Answers |
|:--------:|----------------|
| **V1** Inventory | Do you know what components your software contains? |
| **V2** SBOM | Can you produce a machine-readable, standards-compliant component list? |
| **V3** Build Environment | Is the build process secure and verifiable? |
| **V4** Package Management | Are dependencies acquired and verified securely? |
| **V5** Component Analysis | Are known vulnerabilities identified and remediated? |
| **V6** Pedigree & Provenance | Can you trace each component back to its origin? |

Each category has 3 maturity levels (Basic, Automated, Advanced).

## How SCVS differs from SLSA and SSDF

| Dimension | SCVS | SLSA | SSDF |
|-----------|------|------|------|
| **Scope** | All component verification | Build integrity only | Entire SDLC |
| **Focus** | Components you consume | Artifacts you produce | How you develop software |
| **Strongest domain** | Inventory, SBOM, package mgmt | Build provenance | Organizational governance |
| **Compliance driver** | Voluntary (OWASP) | Voluntary (OpenSSF) | Mandatory for US federal (EO 14028) |

These frameworks work best together. SCVS gives the technical checklist, SLSA the build maturity model, SSDF the organizational governance.

## SCVS maps to WeakLink Labs

| SCVS Category | WeakLink Tier | Key Labs |
|---------------|:------------:|----------|
| V1: Inventory | Tier 4 | 4.1 SBOM Contents |
| V2: SBOM | Tier 4 | 4.1, 4.2, 4.7 |
| V3: Build Environment | Tier 2 | 2.1-2.8 |
| V4: Package Management | Tier 1 | 1.1-1.6 |
| V5: Component Analysis | Tier 7 | 7.1, 7.4 |
| V6: Pedigree & Provenance | Tier 4 | 4.3-4.6 |
