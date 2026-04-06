# Lab 8.2: SSDF / NIST SP 800-218 Mapping

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../assess/" class="phase-step done">Assess</a>
  <span class="phase-arrow">›</span>
  <a href="../plan/" class="phase-step done">Plan</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Document</span>
</div>

**Goal:** Produce an SSDF self-attestation form based on the CISA template.

## CISA self-attestation form

```markdown
SECURE SOFTWARE DEVELOPMENT ATTESTATION FORM
=============================================

Company:          [Organization name]
Software name:    [Product name]
Attestation date: [Date]

SECTION 1: SECURE SOFTWARE DEVELOPMENT PROCESS
[x] Separates and protects each environment involved in developing and building
[x] Employs automated tools to maintain trusted source code supply chains
[ ] Employs automated tools that check for security vulnerabilities
    [Gap: SCA scanning in 60% of repos. Remaining 40% lack automated scanning.]

SECTION 2: SOURCE CODE MANAGEMENT
[x] Maintains provenance of all code incorporated into the software
[ ] Employs automated tools to identify vulnerabilities in source code
    [Gap: No SAST tool deployed.]

SECTION 3: SECURE BUILD ENVIRONMENT
[x] Builds software in a dedicated, ephemeral build environment
[ ] Generates SLSA provenance for built artifacts
    [Gap: Planned for Phase 3 of compliance roadmap.]

SECTION 4: VULNERABILITY MANAGEMENT
[ ] Operates a vulnerability disclosure program [Gap: Planned for Phase 1.]
[x] Provides SBOMs to software consumers upon request
[ ] Has defined remediation timelines [Gap: Planned for Phase 2.]

ATTESTATION GAPS
| Gap | SSDF Task | Target Date |
|-----|-----------|-------------|
| SCA not in all repos | PO.3.1 | [Date] |
| No SLSA provenance | PS.3.1 | [Date] |
| No disclosure policy | RV.2.1 | [Date] |
| No remediation SLAs | RV.3.4 | [Date] |
```

## Guidance for honest attestation

1. Do not attest to what you have not verified.
2. Gaps are acceptable if documented with a Plan of Action & Milestones (POA&M).
3. The attestation is point-in-time. Update it when your posture changes.

## Final verification

```bash
weaklink verify 8.2
```

## What You Learned

- SSDF is not optional for federal suppliers. EO 14028 and CISA self-attestation make it a procurement requirement.
- Technical controls (Tiers 1-5) map well to PS and PW tasks. Organizational practices (PO) and vulnerability response (RV) are the biggest gaps.
- The self-attestation forces honesty about current state and creates accountability for closing gaps.

## Further Reading

- [NIST SP 800-218: Secure Software Development Framework](https://csrc.nist.gov/publications/detail/sp/800-218/final)
- [CISA Secure Software Development Attestation Form](https://www.cisa.gov/secure-software-attestation-form)
- [OMB M-22-18: Enhancing the Security of the Software Supply Chain](https://www.whitehouse.gov/wp-content/uploads/2022/09/M-22-18.pdf)
