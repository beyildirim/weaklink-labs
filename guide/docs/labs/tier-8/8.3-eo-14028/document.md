# Lab 8.3: Executive Order 14028 Compliance

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

**Goal:** Produce a sample SBOM and VEX that meet federal requirements.

## Package deliverables per release

| Deliverable | Format | Delivery Method |
|-------------|--------|-----------------|
| SBOM | CycloneDX JSON (1.5+) | Attached to release or API endpoint |
| VEX | OpenVEX JSON | Attached to release, updated as new CVEs emerge |
| SSDF self-attestation | PDF (signed) | Submitted via CISA portal |
| Vulnerability disclosure policy | Markdown / HTML | Published at well-known URL |

## Ongoing compliance

| Activity | Frequency |
|----------|-----------|
| SBOM generation | Every release (automated) |
| VEX update | When new CVEs are published |
| SSDF self-attestation update | Annually or after significant changes |
| Incident notification drills | Quarterly |

## Final verification

```bash
weaklink verify 8.3
```

## What You Learned

- EO 14028 is a directive, not a suggestion. Federal suppliers must comply with SBOM, VEX, SSDF attestation, vulnerability disclosure, and incident notification.
- VEX reduces false positive fatigue by telling consumers which CVEs in your SBOM are actually exploitable.
- Private sector is converging on these requirements. Large enterprises are beginning to require SBOMs and VEX from vendors.

## Further Reading

- [EO 14028 Full Text](https://www.whitehouse.gov/briefing-room/presidential-actions/2021/05/12/executive-order-on-improving-the-nations-cybersecurity/)
- [NTIA SBOM Minimum Elements](https://www.ntia.gov/sites/default/files/publications/sbom_minimum_elements_report_0.pdf)
- [OpenVEX Specification](https://openvex.dev/)
