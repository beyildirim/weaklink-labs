# Vendor Supply Chain Security Assessment Questionnaire

## Instructions

Send this questionnaire to software vendors as part of your procurement and
ongoing vendor management process. Score each response on the 0-3 scale below.
Require evidence for any claim scored 2 or higher.

**Scoring:**
- **0:** No capability / no response
- **1:** Ad-hoc or informal process exists
- **2:** Documented process, partially implemented
- **3:** Fully implemented, auditable, with evidence

---

## Section 1: Vendor Information

| Field | Response |
|-------|----------|
| Vendor Name | |
| Product Name and Version | |
| Assessment Date | |
| Vendor Contact (Name / Email) | |
| Assessor Name | |

---

## Section 2: Software Bill of Materials

| # | Question | Score (0-3) | Evidence Provided | Notes |
|---|----------|-------------|-------------------|-------|
| 2.1 | Do you generate SBOMs for your software releases? | | | |
| 2.2 | What format are your SBOMs in? (SPDX, CycloneDX, other) | | | |
| 2.3 | Do SBOMs include all transitive dependencies? | | | |
| 2.4 | Are SBOMs provided to customers with each release? | | | |
| 2.5 | How frequently are SBOMs updated? | | | |
| 2.6 | Do SBOMs include component hashes for integrity verification? | | | |

**Section Score:** ___ / 18

---

## Section 3: Build Provenance and Integrity

| # | Question | Score (0-3) | Evidence Provided | Notes |
|---|----------|-------------|-------------------|-------|
| 3.1 | Do you generate build provenance for your releases? | | | |
| 3.2 | What SLSA level does your build process meet? | | | |
| 3.3 | Are artifacts cryptographically signed? | | | |
| 3.4 | Can consumers verify artifact signatures independently? | | | |
| 3.5 | Are builds performed on isolated, ephemeral infrastructure? | | | |
| 3.6 | Is the build process reproducible? | | | |

**Section Score:** ___ / 18

---

## Section 4: Dependency Management

| # | Question | Score (0-3) | Evidence Provided | Notes |
|---|----------|-------------|-------------------|-------|
| 4.1 | Do you use lockfiles to pin dependency versions? | | | |
| 4.2 | Do you scan dependencies for known vulnerabilities? How often? | | | |
| 4.3 | What is your process for evaluating new dependencies? | | | |
| 4.4 | Do you use a private/proxy registry for dependencies? | | | |
| 4.5 | How do you handle deprecated or unmaintained dependencies? | | | |
| 4.6 | Do you track the license compliance of your dependencies? | | | |

**Section Score:** ___ / 18

---

## Section 5: Vulnerability Response

| # | Question | Score (0-3) | Evidence Provided | Notes |
|---|----------|-------------|-------------------|-------|
| 5.1 | Do you have a published vulnerability disclosure policy? | | | |
| 5.2 | What is your SLA for acknowledging reported vulnerabilities? | | | |
| 5.3 | What is your SLA for providing a fix or mitigation? | | | |
| 5.4 | Do you publish security advisories for your products? | | | |
| 5.5 | Do you provide VEX documents to help customers triage? | | | |
| 5.6 | Do you have an incident response plan that covers supply chain incidents? | | | |

**Section Score:** ___ / 18

---

## Section 6: Development Practices

| # | Question | Score (0-3) | Evidence Provided | Notes |
|---|----------|-------------|-------------------|-------|
| 6.1 | Do you require code review for all changes? | | | |
| 6.2 | Do you use SAST and/or DAST tools in your pipeline? | | | |
| 6.3 | Do you perform regular penetration testing? | | | |
| 6.4 | Do developers receive security training? | | | |
| 6.5 | Do you follow a recognized secure development framework (SSDF, SAMM, etc.)? | | | |
| 6.6 | Is your source code management access controlled and audited? | | | |

**Section Score:** ___ / 18

---

## Section 7: Compliance and Certifications

| # | Question | Score (0-3) | Evidence Provided | Notes |
|---|----------|-------------|-------------------|-------|
| 7.1 | Do you hold any security certifications (SOC 2, ISO 27001, FedRAMP)? | | | |
| 7.2 | Can you provide your SSDF self-attestation (per CISA requirements)? | | | |
| 7.3 | Do you comply with EO 14028 requirements? | | | |
| 7.4 | Are you willing to undergo third-party security audits? | | | |

**Section Score:** ___ / 12

---

## Overall Scoring

| Section | Max Score | Actual Score | Percentage |
|---------|-----------|-------------|------------|
| 2. SBOM | 18 | | |
| 3. Build Provenance | 18 | | |
| 4. Dependency Management | 18 | | |
| 5. Vulnerability Response | 18 | | |
| 6. Development Practices | 18 | | |
| 7. Compliance | 12 | | |
| **Total** | **102** | | |

### Risk Rating

| Score Range | Risk Rating | Recommendation |
|-------------|-------------|----------------|
| 85-102 | Low Risk | Approve with standard monitoring |
| 65-84 | Moderate Risk | Approve with enhanced monitoring and improvement plan |
| 45-64 | High Risk | Conditional approval; require remediation within 90 days |
| 0-44 | Critical Risk | Do not approve; require significant improvements before reconsideration |

**Vendor Risk Rating:** _______________
