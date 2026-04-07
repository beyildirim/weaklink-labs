# Lab 8.3: Executive Order 14028 Compliance

<div class="lab-meta">
  <span>Phase 1 ~5 min | Phase 2 ~10 min | Phase 3 ~10 min | Phase 4 ~10 min</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: <a href="../../tier-4/4.1-sbom-contents/">Lab 4.1</a>, <a href="../8.2-ssdf-nist/">Lab 8.2</a></span>
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

EO 14028 is a directive with enforcement mechanisms. It mandates SBOMs, vulnerability disclosure, incident notification timelines, and secure development attestation for every organization selling software to the US federal government.

**Reference:** [EO 14028 Full Text](https://www.whitehouse.gov/briefing-room/presidential-actions/2021/05/12/executive-order-on-improving-the-nations-cybersecurity/)

### Attack Flow

```mermaid
graph TD
    A[EO 14028<br>signed] --> B[NIST publishes<br>SSDF/SP 800-218]
    B --> C[CISA requires<br>self-attestation]
    C --> D[Vendors produce<br>SBOM + VEX]
    D --> E[Federal agencies<br>verify compliance]
```
