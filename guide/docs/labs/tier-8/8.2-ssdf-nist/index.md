# Lab 8.2: SSDF / NIST SP 800-218 Mapping

<div class="lab-meta">
  <span>Understand: ~5 min | Assess: ~15 min | Plan: ~10 min | Document: ~10 min</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: <a href="../../tier-4/4.1-sbom-contents.md">Lab 4.1</a></span>
</div>

<div class="phase-stepper">
  <span class="phase-step current">Overview</span>
  <span class="phase-arrow">›</span>
  <a href="understand/" class="phase-step upcoming">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="assess/" class="phase-step upcoming">Assess</a>
  <span class="phase-arrow">›</span>
  <a href="plan/" class="phase-step upcoming">Plan</a>
  <span class="phase-arrow">›</span>
  <a href="document/" class="phase-step upcoming">Document</a>
</div>

The Secure Software Development Framework (SSDF), published as [NIST SP 800-218](https://csrc.nist.gov/publications/detail/sp/800-218/final), defines how organizations should develop secure software. Executive Order 14028 requires federal software suppliers to self-attest compliance. If your organization sells software to the US government, this is mandatory.

**Reference:** [NIST SP 800-218](https://csrc.nist.gov/publications/detail/sp/800-218/final) | [CISA Self-Attestation Form](https://www.cisa.gov/secure-software-attestation-form)

### Attack Flow

```mermaid
graph TD
    A[Prepare Organization<br>PO] --> B[Protect Software<br>PS]
    B --> C[Produce Secure<br>Software PW]
    C --> D[Respond to<br>Vulnerabilities RV]
    D --> E[Self-Attestation<br>to CISA]
```
