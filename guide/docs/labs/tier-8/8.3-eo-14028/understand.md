# Lab 8.3: Executive Order 14028 Compliance

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

**Goal:** Learn the five specific requirements of EO 14028 Section 4.

## The five key requirements

**1. Software Bill of Materials (SBOM)**
SPDX or CycloneDX format, machine-readable, provided with each release, covering all components including open-source. Must meet [NTIA minimum elements](https://www.ntia.gov/sites/default/files/publications/sbom_minimum_elements_report_0.pdf).

**2. Vulnerability Disclosure**
Published disclosure policy, process for receiving external reports, commitment to timely remediation.

**3. Incident Notification**
Notify federal customers within 72 hours of confirmed incident. Include scope, impact, remediation actions, timeline.

**4. Secure Development Attestation**
Self-attest to SSDF compliance via [CISA attestation form](https://www.cisa.gov/secure-software-attestation-form). (Covered in [Lab 8.2](../8.2-ssdf-nist/).)

**5. Vulnerability Exploitability Exchange (VEX)**
Communicate exploitability status of known CVEs in your product. Formats: CSAF, CycloneDX VEX, or [OpenVEX](https://openvex.dev/).

## NTIA SBOM minimum elements

| Element | Example |
|---------|---------|
| Supplier name | "Python Software Foundation" |
| Component name | "requests" |
| Component version | "2.31.0" |
| Unique identifier | "pkg:pypi/requests@2.31.0" |
| Dependency relationship | "requests DEPENDS_ON urllib3" |
| Author of SBOM | "WeakLink Corp build system" |
| Timestamp | "2026-04-01T12:00:00Z" |
