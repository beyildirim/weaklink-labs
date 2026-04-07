# SCVS Compliance Report

## Executive Summary

| Field | Value |
|-------|-------|
| Organization | |
| Application / Project | |
| Report Date | |
| Prepared By | |
| SCVS Version | 1.0 |
| Overall Maturity Level | Level ___ of 3 |

### Maturity Summary

| Category | Current Level | Target Level | Gap |
|----------|:------------:|:------------:|:---:|
| V1: Inventory | | | |
| V2: SBOM | | | |
| V3: Build Environment | | | |
| V4: Package Management | | | |
| V5: Component Analysis | | | |
| V6: Pedigree & Provenance | | | |

---

## Assessment Methodology

- **Scope:** [Describe the application, repositories, and build pipelines assessed]
- **Assessment type:** [Self-assessment / third-party / automated tooling]
- **Evidence collection:** [How evidence was gathered: CI logs, tool output, interviews]
- **Limitations:** [Any constraints on the assessment]

---

## Detailed Findings by Category

### V1: Inventory

**Current Level:** ___

**Strengths:**

- [List what is working well]

**Gaps:**

| Gap | Severity | Remediation | Effort | WeakLink Lab |
|-----|:--------:|-------------|:------:|:------------:|
| | High / Medium / Low | | | |
| | High / Medium / Low | | | |

**Checklist for V1 Level 2:**

- [ ] Automate inventory generation in CI/CD pipeline
- [ ] Include cryptographic hashes for all components
- [ ] Include source repository URLs for all components
- [ ] Ensure inventory updates on every dependency change

---

### V2: Software Bill of Materials

**Current Level:** ___

**Strengths:**

- [List what is working well]

**Gaps:**

| Gap | Severity | Remediation | Effort | WeakLink Lab |
|-----|:--------:|-------------|:------:|:------------:|
| | High / Medium / Low | | | |
| | High / Medium / Low | | | |

**Checklist for V2 Level 2:**

- [ ] Generate SBOMs in CycloneDX or SPDX format
- [ ] Include all transitive dependencies in SBOMs
- [ ] Include cryptographic hashes for each component
- [ ] Include license information for each component
- [ ] Automate SBOM generation in CI/CD
- [ ] Make SBOMs available to software consumers

---

### V3: Build Environment

**Current Level:** ___

**Strengths:**

- [List what is working well]

**Gaps:**

| Gap | Severity | Remediation | Effort | WeakLink Lab |
|-----|:--------:|-------------|:------:|:------------:|
| | High / Medium / Low | | | |
| | High / Medium / Low | | | |

**Checklist for V3 Level 2:**

- [ ] Use ephemeral build environments (fresh per build)
- [ ] Generate signed provenance attestations
- [ ] Pin all build tools and plugins to exact versions/hashes
- [ ] Use a secrets manager for build secrets (no hardcoded values)

---

### V4: Package Management

**Current Level:** ___

**Strengths:**

- [List what is working well]

**Gaps:**

| Gap | Severity | Remediation | Effort | WeakLink Lab |
|-----|:--------:|-------------|:------:|:------------:|
| | High / Medium / Low | | | |
| | High / Medium / Low | | | |

**Checklist for V4 Level 2:**

- [ ] Verify dependency hashes during installation (`--require-hashes`)
- [ ] Require review for new dependency adoption
- [ ] Evaluate dependency health before adoption
- [ ] Enable automated dependency updates with human review

---

### V5: Component Analysis

**Current Level:** ___

**Strengths:**

- [List what is working well]

**Gaps:**

| Gap | Severity | Remediation | Effort | WeakLink Lab |
|-----|:--------:|-------------|:------:|:------------:|
| | High / Medium / Low | | | |
| | High / Medium / Low | | | |

**Checklist for V5 Level 2:**

- [ ] Run vulnerability scanning automatically in CI/CD
- [ ] Define remediation SLAs (Critical: 48h, High: 7d, Medium: 30d, Low: 90d)
- [ ] Block deployments when severity thresholds are exceeded
- [ ] Track all vulnerability findings in a centralized system

---

### V6: Pedigree and Provenance

**Current Level:** ___

**Strengths:**

- [List what is working well]

**Gaps:**

| Gap | Severity | Remediation | Effort | WeakLink Lab |
|-----|:--------:|-------------|:------:|:------------:|
| | High / Medium / Low | | | |
| | High / Medium / Low | | | |

**Checklist for V6 Level 2:**

- [ ] Verify component signatures or checksums before use
- [ ] Obtain provenance attestations for critical components
- [ ] Evaluate upstream project health (OpenSSF Scorecard or equivalent)

---

## Remediation Roadmap

### Priority 1: Critical (0-30 days)

| # | Action | SCVS Control | Effort | Owner |
|:-:|--------|-------------|:------:|-------|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |

### Priority 2: High (30-90 days)

| # | Action | SCVS Control | Effort | Owner |
|:-:|--------|-------------|:------:|-------|
| 4 | | | | |
| 5 | | | | |
| 6 | | | | |

### Priority 3: Medium (90-180 days)

| # | Action | SCVS Control | Effort | Owner |
|:-:|--------|-------------|:------:|-------|
| 7 | | | | |
| 8 | | | | |
| 9 | | | | |

---

## Framework Overlap Summary

Controls that satisfy multiple frameworks simultaneously (highest ROI):

| Remediation Action | SCVS | SLSA | SSDF | EO 14028 |
|-------------------|:----:|:----:|:----:|:--------:|
| Generate SBOMs for all releases | V2 | -- | RV.3.3 | Required |
| Sign all artifacts with cosign | V3, V6 | L2 | PS.3.1 | -- |
| Automate vulnerability scanning in CI | V5 | -- | PW.7.2 | Required |
| Implement SLSA provenance | V3, V6 | L1-L3 | PS.3.1 | -- |
| Verify dependency hashes | V4 | -- | PW.4.4 | -- |
| Define remediation SLAs | V5 | -- | RV.3.4 | Required |

---

## Continuous Monitoring Plan

| Metric | Current | Target (90d) | Target (180d) | Tool |
|--------|:-------:|:------------:|:-------------:|------|
| SCVS V1 maturity level | | | | |
| SCVS V2 maturity level | | | | |
| SCVS V3 maturity level | | | | |
| SCVS V4 maturity level | | | | |
| SCVS V5 maturity level | | | | |
| SCVS V6 maturity level | | | | |
| % releases with SBOM | | | | |
| % artifacts signed | | | | |
| Mean time to remediate critical CVE | | | | |
| % dependencies with verified hashes | | | | |

---

## Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Report Author | | | |
| Engineering Lead | | | |
| Security Lead | | | |
| CISO / Executive Sponsor | | | |
