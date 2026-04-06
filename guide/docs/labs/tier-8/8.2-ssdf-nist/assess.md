# Lab 8.2: SSDF / NIST SP 800-218 Mapping

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Assess</span>
  <span class="phase-arrow">›</span>
  <a href="../plan/" class="phase-step upcoming">Plan</a>
  <span class="phase-arrow">›</span>
  <a href="../document/" class="phase-step upcoming">Document</a>
</div>

**Goal:** Map Tiers 1-5 defenses to SSDF practices and identify coverage gaps.

## Map Tier 1 (Package Security)

| Lab | Defense | SSDF Task | Status |
|-----|---------|-----------|--------|
| 1.2 Dependency Confusion | `--index-url`, `--require-hashes` | PW.4.4 | Preventive control |
| 1.3 Typosquatting | Lockfile pinning, review new deps | PW.4.1, PW.4.4 | Preventive control |
| 1.4 Lockfile Injection | Validate lockfile integrity in CI | PS.2.1 | Detective control |
| 1.6 Phantom Dependencies | Declare all dependencies explicitly | PW.4.1 | Preventive control |

## Map Tiers 2-5

| Lab | Defense | SSDF Task |
|-----|---------|-----------|
| 2.x CI/CD Security | Harden GitHub Actions workflows | PS.2.1 |
| 3.x Container Security | Image signing, digest pinning | PS.3.1, PW.4.4 |
| 4.1 SBOM Contents | Generate SBOMs | RV.3.3 |
| 4.4 SLSA Provenance | Build provenance attestations | PS.3.1, PW.4.4 |
| 5.x Runtime Security | Monitor deployed software | RV.1.1 |

## Coverage gaps

| SSDF Task | Gap |
|-----------|-----|
| PO.1.1 | No documented security policy |
| PO.2.1 | No supply chain security training program |
| PO.5.1 | No security gate criteria for deployments |
| PW.1.1 | No threat modeling during design phase |
| RV.2.1 | No vulnerability disclosure process |
| RV.3.4 | No defined patching timelines |

**Key finding:** Tiers 1-5 cover the technical controls well (PS and PW). Organizational practices (PO) and vulnerability response (RV) have significant gaps. This is typical: tools before governance.

---

!!! success "Checkpoint"
    You should have a mapping of at least 10 WeakLink Lab defenses to SSDF tasks, plus a list of uncovered gaps. The gaps should be concentrated in PO and RV practice areas.
