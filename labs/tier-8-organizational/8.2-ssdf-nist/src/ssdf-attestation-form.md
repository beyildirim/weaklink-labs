# Secure Software Development Attestation Form

Based on CISA Secure Software Development Self-Attestation Form (OMB M-22-18, M-23-16)

---

## Section 1: Software Producer Information

| Field | Value |
|-------|-------|
| Company / Organization Name | |
| Point of Contact Name | |
| Point of Contact Email | |
| Software Name and Version | |
| Date of Attestation | |

---

## Section 2: Attestation

The software producer listed above attests that the following practices are
consistently applied to the development of the software identified above,
in conformance with the NIST Secure Software Development Framework (SP 800-218).

### Secure Development Environment

- [ ] **2a.** The software is developed and built in secure environments. These
  environments are secured by actions that, at minimum, include: separation of
  build environments from other environments, use of multi-factor authentication,
  conditional access policies, use of encryption for data at rest, logging and
  monitoring of operations and alerts in the build environment, and enforcement of
  the principle of least privilege.

### Source Code Management

- [ ] **2b.** The software producer has made a good-faith effort to maintain trusted
  source code supply chains by employing automated tools or comparable processes
  to check for known and potential vulnerabilities and addressing them prior to
  release.

- [ ] **2c.** The software producer maintains provenance data for internal and third-party
  code incorporated into the software, including open-source software.

### Build Integrity

- [ ] **2d.** The software producer employs automated tools or comparable processes that
  check for security vulnerabilities. Where such tools or processes are used,
  the producer operates them on an ongoing basis and remediates findings prior
  to release.

- [ ] **2e.** The software producer uses a software bill of materials (SBOM) to track and
  manage open-source and third-party components.

### Vulnerability Management

- [ ] **2f.** The software producer has an established vulnerability disclosure program
  that includes a reporting mechanism accessible to the public and a process for
  timely review and response.

- [ ] **2g.** The software producer attests that the software has been developed with
  practices consistent with the NIST SSDF.

---

## Section 3: Practices Detail

For each practice area, describe the specific measures in place:

### Development Environment Security (2a)

| Control | Implementation | Evidence |
|---------|---------------|----------|
| Build environment isolation | | |
| Multi-factor authentication | | |
| Encryption at rest | | |
| Logging and monitoring | | |
| Least privilege access | | |

### Source Code Supply Chain (2b)

| Control | Implementation | Evidence |
|---------|---------------|----------|
| Dependency scanning | | |
| SAST/DAST tooling | | |
| Pre-release vulnerability assessment | | |

### Provenance (2c)

| Control | Implementation | Evidence |
|---------|---------------|----------|
| Internal code provenance tracking | | |
| Third-party component provenance | | |
| Open-source dependency provenance | | |

### Vulnerability Scanning (2d)

| Control | Implementation | Evidence |
|---------|---------------|----------|
| Automated vulnerability scanning | | |
| Frequency of scans | | |
| Remediation SLA | | |

### SBOM Management (2e)

| Control | Implementation | Evidence |
|---------|---------------|----------|
| SBOM generation tooling | | |
| SBOM format (SPDX/CycloneDX) | | |
| SBOM update frequency | | |
| SBOM distribution to consumers | | |

### Vulnerability Disclosure (2f)

| Control | Implementation | Evidence |
|---------|---------------|----------|
| Public reporting mechanism | | |
| Response timeline SLA | | |
| Disclosure policy URL | | |

---

## Section 4: Exceptions and Deviations

List any attestation items that cannot be fully met and explain why:

| Item | Deviation | Compensating Control | Remediation Plan |
|------|-----------|---------------------|-----------------|
| | | | |
| | | | |

---

## Section 5: Sign-Off

I attest that the information provided above is accurate and that the practices
described are consistently applied to the identified software.

| Role | Name | Title | Date | Signature |
|------|------|-------|------|-----------|
| Attesting Official | | | | |
| Engineering Lead | | | | |
| Security Lead | | | | |

---

*This form is modeled on the CISA Secure Software Development Self-Attestation
Common Form. For actual federal submissions, use the official CISA form at
https://www.cisa.gov/secure-software-attestation-form*
