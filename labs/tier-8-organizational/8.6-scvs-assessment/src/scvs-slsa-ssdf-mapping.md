# Framework Overlap Matrix: SCVS / SLSA / SSDF / EO 14028

## How to Use This Document

This matrix maps OWASP SCVS verification categories to equivalent requirements in SLSA, SSDF (NIST SP 800-218), and Executive Order 14028. Use it to identify controls that satisfy multiple frameworks simultaneously and to avoid duplicating compliance efforts.

---

## V1: Inventory

| SCVS Control | SLSA Equivalent | SSDF Equivalent | EO 14028 Requirement |
|-------------|-----------------|-----------------|---------------------|
| V1.1 Component catalog (direct deps) | -- | PW.4.1 (acquire well-secured components) | SBOM must list components |
| V1.2 Transitive dependency tracking | -- | PW.4.1 | SBOM must include transitive deps |
| V1.3 Automated inventory generation | -- | PO.3.1 (specify and use tools) | -- |
| V1.L3 Centralized queryable inventory | -- | PO.3.2 (automated compliance checks) | -- |

**Key insight:** SLSA does not address inventory directly. Inventory is primarily an SBOM/SCVS and SSDF concern.

---

## V2: Software Bill of Materials

| SCVS Control | SLSA Equivalent | SSDF Equivalent | EO 14028 Requirement |
|-------------|-----------------|-----------------|---------------------|
| V2.1 SBOM generated | -- | RV.3.3 (provide SBOMs to consumers) | SBOMs required for federal software |
| V2.2 Standard format (CycloneDX/SPDX) | -- | RV.3.3 | Machine-readable format required |
| V2.3 Includes hashes and licenses | -- | PW.4.4 (verify component integrity) | NTIA minimum elements |
| V2.L2 Automated SBOM in CI/CD | -- | PO.3.2 (automated tools) | -- |
| V2.L3 Signed SBOM | -- | PS.3.1 (protect releases) | -- |
| V2.L3 VEX documents | -- | RV.1.1 (gather vuln info) | VEX recommended by CISA |

**Key insight:** EO 14028 is the strongest driver for SBOM requirements. SCVS V2 and SSDF RV.3.3 both address SBOM delivery but SCVS goes deeper on SBOM quality.

---

## V3: Build Environment

| SCVS Control | SLSA Equivalent | SSDF Equivalent | EO 14028 Requirement |
|-------------|-----------------|-----------------|---------------------|
| V3.1 Scripted, repeatable build | SLSA L1 (provenance exists) | PS.2.1 (protect code/build) | Secure development practices |
| V3.2 Hosted build platform | SLSA L2 (hosted build) | PS.2.1 | -- |
| V3.2 Signed provenance | SLSA L2 (authenticated provenance) | PS.3.1 (protect releases) | -- |
| V3.2 Build tools pinned to versions | SLSA L3 prep | PW.4.4 (verify integrity) | -- |
| V3.3 Ephemeral build environment | SLSA L3 (isolated builds) | PS.2.1 | -- |
| V3.3 Hermetic build | SLSA L3 (parameterless) | PS.2.1 | -- |
| V3.3 Non-falsifiable provenance | SLSA L3 | PS.3.1 | -- |
| V3.3 Reproducible build | SLSA best practice (formerly L4) | -- | -- |

**Key insight:** SCVS V3 and SLSA overlap almost completely. An organization that achieves SLSA Level 3 will satisfy most SCVS V3 Level 3 controls.

---

## V4: Package Management

| SCVS Control | SLSA Equivalent | SSDF Equivalent | EO 14028 Requirement |
|-------------|-----------------|-----------------|---------------------|
| V4.1 Manifest and lockfile | -- | PW.4.1 (acquire well-secured components) | -- |
| V4.1 Trusted registries | -- | PW.4.1 | -- |
| V4.1 Namespace separation | -- | PW.4.4 (verify integrity) | -- |
| V4.2 Hash verification | -- | PW.4.4 | -- |
| V4.2 Dependency review process | -- | PW.4.1 | -- |
| V4.3 Curated registry/proxy | -- | PO.3.1 (specify tools) | -- |
| V4.3 Behavioral analysis | -- | PW.7.2 (automated testing) | -- |

**Key insight:** SLSA does not cover package management at all -- it focuses on build integrity. SCVS V4 aligns with SSDF PW.4.x practices. This is the area where WeakLink Labs Tier 1 provides the most direct coverage.

---

## V5: Component Analysis

| SCVS Control | SLSA Equivalent | SSDF Equivalent | EO 14028 Requirement |
|-------------|-----------------|-----------------|---------------------|
| V5.1 CVE identification | -- | RV.1.1 (gather vuln info) | Automated tools required |
| V5.1 Vulnerability scanning | -- | PW.7.2 (automated testing) | Automated tools required |
| V5.2 Automated scanning in CI/CD | -- | PO.3.2 (automated compliance) | -- |
| V5.2 Remediation SLAs | -- | RV.3.4 (remediation timelines) | Timely remediation required |
| V5.2 Severity-based deployment gates | -- | PO.5.1 (secure dev criteria) | -- |
| V5.3 VEX generation | -- | RV.1.1, RV.3.3 | VEX recommended |
| V5.3 Exploitability analysis | -- | RV.1.2 (assess vulnerabilities) | -- |

**Key insight:** SCVS V5 and SSDF RV practices overlap significantly. SLSA does not address vulnerability management.

---

## V6: Pedigree and Provenance

| SCVS Control | SLSA Equivalent | SSDF Equivalent | EO 14028 Requirement |
|-------------|-----------------|-----------------|---------------------|
| V6.1 Source repository known | SLSA L1 (source reference in provenance) | PW.4.1 | -- |
| V6.1 Canonical sources | -- | PW.4.1 | -- |
| V6.2 Signature/checksum verification | SLSA L2 (authenticated provenance) | PW.4.4 | -- |
| V6.2 Provenance attestations | SLSA L1-L3 (core requirement) | PS.3.1 | -- |
| V6.2 Upstream health evaluation | -- | PW.4.1 | -- |
| V6.3 Full chain of custody | SLSA L3 (non-falsifiable provenance) | PS.3.1 | Provenance recommended |
| V6.3 Provenance verified at deploy | SLSA verification policy | PO.5.1 | -- |

**Key insight:** SCVS V6 and SLSA overlap on provenance, but SCVS goes broader to include upstream health evaluation and chain of custody documentation that SLSA does not address.

---

## Summary: Framework Strength by Domain

| Domain | SCVS | SLSA | SSDF | EO 14028 |
|--------|:----:|:----:|:----:|:--------:|
| Component inventory | Strong | None | Moderate | Moderate |
| SBOM quality | Strong | None | Moderate | Strong |
| Build integrity | Strong | **Primary focus** | Moderate | Weak |
| Package management | Strong | None | Moderate | Weak |
| Vulnerability management | Strong | None | Strong | Moderate |
| Provenance/pedigree | Strong | **Primary focus** | Moderate | Moderate |
| Organizational governance | Weak | None | **Primary focus** | Strong |
| Incident response | None | None | Strong | Moderate |

**Recommendation:** Use SCVS as the comprehensive technical checklist, SLSA for build integrity maturity, SSDF for organizational governance, and EO 14028 as the regulatory baseline. Combined, they provide complete coverage with minimal redundancy.

---

## WeakLink Labs Tier Mapping

| SCVS Category | Primary WeakLink Tier | Key Labs |
|---------------|----------------------|----------|
| V1: Inventory | Tier 4 (Artifact Integrity) | 4.1, 4.2 |
| V2: SBOM | Tier 4 (Artifact Integrity) | 4.1, 4.2, 4.7 |
| V3: Build Environment | Tier 2 (Build & CI/CD) | 2.1-2.8 |
| V4: Package Management | Tier 1 (Package Security) | 1.1-1.6 |
| V5: Component Analysis | Tier 7 (Detection & Response) | 7.1, 7.4 |
| V6: Pedigree & Provenance | Tier 4 (Artifact Integrity) | 4.3, 4.4, 4.5, 4.6 |
