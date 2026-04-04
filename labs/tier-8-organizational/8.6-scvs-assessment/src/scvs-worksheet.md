# SCVS Assessment Worksheet

## Organization Information

| Field | Value |
|-------|-------|
| Organization | |
| Application / Project | |
| Assessment Date | |
| Assessor Name | |
| SCVS Specification Version | 1.0 |

---

## V1: Inventory -- Knowing What You Have

### Level 1

| # | Control | Met? | Evidence / Notes |
|---|---------|------|------------------|
| V1.1.1 | All direct dependencies are identified and cataloged | [ ] Met / [ ] Partial / [ ] Not Met | |
| V1.1.2 | All transitive dependencies are identified and cataloged | [ ] Met / [ ] Partial / [ ] Not Met | |
| V1.1.3 | The inventory includes component name, version, and license | [ ] Met / [ ] Partial / [ ] Not Met | |
| V1.1.4 | The inventory is updated when dependencies change | [ ] Met / [ ] Partial / [ ] Not Met | |

### Level 2

| # | Control | Met? | Evidence / Notes |
|---|---------|------|------------------|
| V1.2.1 | Inventory generation is automated (not manual) | [ ] Met / [ ] Partial / [ ] Not Met | |
| V1.2.2 | Inventory includes the hash/digest of each component | [ ] Met / [ ] Partial / [ ] Not Met | |
| V1.2.3 | Inventory includes the source repository of each component | [ ] Met / [ ] Partial / [ ] Not Met | |
| V1.2.4 | Inventory is generated as part of the CI/CD pipeline | [ ] Met / [ ] Partial / [ ] Not Met | |

### Level 3

| # | Control | Met? | Evidence / Notes |
|---|---------|------|------------------|
| V1.3.1 | Inventory is stored in a centralized, queryable system | [ ] Met / [ ] Partial / [ ] Not Met | |
| V1.3.2 | Historical inventory is retained for all releases | [ ] Met / [ ] Partial / [ ] Not Met | |
| V1.3.3 | Inventory is correlated across all applications in the organization | [ ] Met / [ ] Partial / [ ] Not Met | |

**V1 Summary:**

- Level 1: ___ / 4 controls met
- Level 2: ___ / 4 controls met
- Level 3: ___ / 3 controls met
- **V1 Maturity Level:** ___

---

## V2: Software Bill of Materials -- SBOM Quality

### Level 1

| # | Control | Met? | Evidence / Notes |
|---|---------|------|------------------|
| V2.1.1 | An SBOM is generated for the application | [ ] Met / [ ] Partial / [ ] Not Met | |
| V2.1.2 | SBOM is in a standard format (CycloneDX or SPDX) | [ ] Met / [ ] Partial / [ ] Not Met | |
| V2.1.3 | SBOM includes all direct dependencies | [ ] Met / [ ] Partial / [ ] Not Met | |
| V2.1.4 | SBOM includes component name, version, and supplier | [ ] Met / [ ] Partial / [ ] Not Met | |

### Level 2

| # | Control | Met? | Evidence / Notes |
|---|---------|------|------------------|
| V2.2.1 | SBOM includes all transitive dependencies | [ ] Met / [ ] Partial / [ ] Not Met | |
| V2.2.2 | SBOM includes cryptographic hashes for each component | [ ] Met / [ ] Partial / [ ] Not Met | |
| V2.2.3 | SBOM includes license information for each component | [ ] Met / [ ] Partial / [ ] Not Met | |
| V2.2.4 | SBOM is generated automatically in CI/CD | [ ] Met / [ ] Partial / [ ] Not Met | |
| V2.2.5 | SBOM is available to consumers of the software | [ ] Met / [ ] Partial / [ ] Not Met | |

### Level 3

| # | Control | Met? | Evidence / Notes |
|---|---------|------|------------------|
| V2.3.1 | SBOM is signed to ensure integrity and authenticity | [ ] Met / [ ] Partial / [ ] Not Met | |
| V2.3.2 | SBOM includes vulnerability disclosure information (VEX) | [ ] Met / [ ] Partial / [ ] Not Met | |
| V2.3.3 | SBOM includes pedigree information (origin, transformation) | [ ] Met / [ ] Partial / [ ] Not Met | |
| V2.3.4 | SBOM conforms to NTIA minimum elements for SBOMs | [ ] Met / [ ] Partial / [ ] Not Met | |

**V2 Summary:**

- Level 1: ___ / 4 controls met
- Level 2: ___ / 5 controls met
- Level 3: ___ / 4 controls met
- **V2 Maturity Level:** ___

---

## V3: Build Environment -- Build Integrity

### Level 1

| # | Control | Met? | Evidence / Notes |
|---|---------|------|------------------|
| V3.1.1 | The build process is scripted and repeatable | [ ] Met / [ ] Partial / [ ] Not Met | |
| V3.1.2 | Build runs on a CI/CD platform (not developer workstations) | [ ] Met / [ ] Partial / [ ] Not Met | |
| V3.1.3 | Build tools are documented with their versions | [ ] Met / [ ] Partial / [ ] Not Met | |

### Level 2

| # | Control | Met? | Evidence / Notes |
|---|---------|------|------------------|
| V3.2.1 | Build environment is ephemeral (fresh per build) | [ ] Met / [ ] Partial / [ ] Not Met | |
| V3.2.2 | Build produces signed provenance attestations | [ ] Met / [ ] Partial / [ ] Not Met | |
| V3.2.3 | Build tools and plugins are pinned to exact versions/hashes | [ ] Met / [ ] Partial / [ ] Not Met | |
| V3.2.4 | Build secrets are managed via a secrets manager (not hardcoded) | [ ] Met / [ ] Partial / [ ] Not Met | |

### Level 3

| # | Control | Met? | Evidence / Notes |
|---|---------|------|------------------|
| V3.3.1 | Build is hermetic (no network access during compilation) | [ ] Met / [ ] Partial / [ ] Not Met | |
| V3.3.2 | Build provenance is non-falsifiable by build tenants | [ ] Met / [ ] Partial / [ ] Not Met | |
| V3.3.3 | Build is reproducible (same inputs produce identical output) | [ ] Met / [ ] Partial / [ ] Not Met | |
| V3.3.4 | Build environment hardened against insider threats | [ ] Met / [ ] Partial / [ ] Not Met | |

**V3 Summary:**

- Level 1: ___ / 3 controls met
- Level 2: ___ / 4 controls met
- Level 3: ___ / 4 controls met
- **V3 Maturity Level:** ___

---

## V4: Package Management -- Dependency Controls

### Level 1

| # | Control | Met? | Evidence / Notes |
|---|---------|------|------------------|
| V4.1.1 | Dependencies are declared in a manifest file | [ ] Met / [ ] Partial / [ ] Not Met | |
| V4.1.2 | A lockfile pins dependencies to specific versions | [ ] Met / [ ] Partial / [ ] Not Met | |
| V4.1.3 | Dependencies are downloaded from trusted registries | [ ] Met / [ ] Partial / [ ] Not Met | |
| V4.1.4 | Private and public package namespaces are separated | [ ] Met / [ ] Partial / [ ] Not Met | |

### Level 2

| # | Control | Met? | Evidence / Notes |
|---|---------|------|------------------|
| V4.2.1 | Dependency hashes are verified during installation | [ ] Met / [ ] Partial / [ ] Not Met | |
| V4.2.2 | New dependencies require review before adoption | [ ] Met / [ ] Partial / [ ] Not Met | |
| V4.2.3 | A process exists for evaluating dependency health (maintenance, popularity) | [ ] Met / [ ] Partial / [ ] Not Met | |
| V4.2.4 | Automated updates are enabled with human review (e.g., Dependabot) | [ ] Met / [ ] Partial / [ ] Not Met | |

### Level 3

| # | Control | Met? | Evidence / Notes |
|---|---------|------|------------------|
| V4.3.1 | Dependencies are sourced from a curated, vetted registry or proxy | [ ] Met / [ ] Partial / [ ] Not Met | |
| V4.3.2 | Behavioral analysis is performed on dependencies (install scripts, network access) | [ ] Met / [ ] Partial / [ ] Not Met | |
| V4.3.3 | Dependency license compliance is enforced automatically | [ ] Met / [ ] Partial / [ ] Not Met | |
| V4.3.4 | Unused and deprecated dependencies are identified and removed | [ ] Met / [ ] Partial / [ ] Not Met | |

**V4 Summary:**

- Level 1: ___ / 4 controls met
- Level 2: ___ / 4 controls met
- Level 3: ___ / 4 controls met
- **V4 Maturity Level:** ___

---

## V5: Component Analysis -- Vulnerability Management

### Level 1

| # | Control | Met? | Evidence / Notes |
|---|---------|------|------------------|
| V5.1.1 | Known vulnerabilities (CVEs) are identified in dependencies | [ ] Met / [ ] Partial / [ ] Not Met | |
| V5.1.2 | A vulnerability scanning tool runs against the project | [ ] Met / [ ] Partial / [ ] Not Met | |
| V5.1.3 | Vulnerabilities with available patches are remediated | [ ] Met / [ ] Partial / [ ] Not Met | |

### Level 2

| # | Control | Met? | Evidence / Notes |
|---|---------|------|------------------|
| V5.2.1 | Vulnerability scanning is automated in CI/CD | [ ] Met / [ ] Partial / [ ] Not Met | |
| V5.2.2 | Vulnerability remediation SLAs are defined (Critical, High, Medium, Low) | [ ] Met / [ ] Partial / [ ] Not Met | |
| V5.2.3 | Vulnerability scan results block deployment if severity thresholds are exceeded | [ ] Met / [ ] Partial / [ ] Not Met | |
| V5.2.4 | Vulnerability findings are tracked in a centralized system | [ ] Met / [ ] Partial / [ ] Not Met | |

### Level 3

| # | Control | Met? | Evidence / Notes |
|---|---------|------|------------------|
| V5.3.1 | VEX documents are generated to communicate vulnerability applicability | [ ] Met / [ ] Partial / [ ] Not Met | |
| V5.3.2 | Risk-based analysis determines actual exploitability (not just CVE presence) | [ ] Met / [ ] Partial / [ ] Not Met | |
| V5.3.3 | Vulnerability intelligence feeds are integrated (OSV, NVD, vendor advisories) | [ ] Met / [ ] Partial / [ ] Not Met | |
| V5.3.4 | Component end-of-life / end-of-support tracking is in place | [ ] Met / [ ] Partial / [ ] Not Met | |

**V5 Summary:**

- Level 1: ___ / 3 controls met
- Level 2: ___ / 4 controls met
- Level 3: ___ / 4 controls met
- **V5 Maturity Level:** ___

---

## V6: Pedigree and Provenance -- Origin Tracking

### Level 1

| # | Control | Met? | Evidence / Notes |
|---|---------|------|------------------|
| V6.1.1 | The source repository for each component is known | [ ] Met / [ ] Partial / [ ] Not Met | |
| V6.1.2 | Components are obtained from their canonical source (not mirrors or forks) | [ ] Met / [ ] Partial / [ ] Not Met | |
| V6.1.3 | Component authors/maintainers are identified | [ ] Met / [ ] Partial / [ ] Not Met | |

### Level 2

| # | Control | Met? | Evidence / Notes |
|---|---------|------|------------------|
| V6.2.1 | Component signatures or checksums are verified before use | [ ] Met / [ ] Partial / [ ] Not Met | |
| V6.2.2 | Provenance attestations are available for critical components | [ ] Met / [ ] Partial / [ ] Not Met | |
| V6.2.3 | Upstream project health is evaluated (OpenSSF Scorecard or equivalent) | [ ] Met / [ ] Partial / [ ] Not Met | |

### Level 3

| # | Control | Met? | Evidence / Notes |
|---|---------|------|------------------|
| V6.3.1 | Full chain of custody is documented from source to deployment | [ ] Met / [ ] Partial / [ ] Not Met | |
| V6.3.2 | Provenance attestations are verified before deployment | [ ] Met / [ ] Partial / [ ] Not Met | |
| V6.3.3 | Components with unknown or unverifiable provenance are flagged and reviewed | [ ] Met / [ ] Partial / [ ] Not Met | |

**V6 Summary:**

- Level 1: ___ / 3 controls met
- Level 2: ___ / 3 controls met
- Level 3: ___ / 3 controls met
- **V6 Maturity Level:** ___

---

## Overall Assessment Summary

| Category | Level 1 | Level 2 | Level 3 | Maturity Level |
|----------|:-------:|:-------:|:-------:|:--------------:|
| V1: Inventory | / 4 | / 4 | / 3 | |
| V2: SBOM | / 4 | / 5 | / 4 | |
| V3: Build Environment | / 3 | / 4 | / 4 | |
| V4: Package Management | / 4 | / 4 | / 4 | |
| V5: Component Analysis | / 3 | / 4 | / 4 | |
| V6: Pedigree & Provenance | / 3 | / 3 | / 3 | |

**Overall SCVS Maturity Level:** ___

---

## Gap-to-Lab Mapping

For each identified gap, map it to the WeakLink Labs tier and lab where the defense is taught:

| SCVS Category | Gap | WeakLink Lab | Tier |
|---------------|-----|-------------|------|
| | | | |
| | | | |
| | | | |
| | | | |
| | | | |
| | | | |

---

## Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Assessor | | | |
| Engineering Lead | | | |
| Security Lead | | | |
