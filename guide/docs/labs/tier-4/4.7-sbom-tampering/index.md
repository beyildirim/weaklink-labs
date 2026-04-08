# Lab 4.7: SBOM Tampering

<div class="lab-meta">
  <span>Understand: ~5 min | Break: ~5 min | Defend: ~5 min | Detect: ~15 min</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: <a href="../4.1-sbom-contents/">Lab 4.1</a>, <a href="../4.3-signing-fundamentals/">Lab 4.3</a></span>
</div>

<div class="phase-stepper">
  <span class="phase-step current">Overview</span>
  <span class="phase-arrow">›</span>
  <a href="understand/" class="phase-step upcoming">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="break/" class="phase-step upcoming">Break</a>
  <span class="phase-arrow">›</span>
  <a href="defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="detect/" class="phase-step upcoming">Detect</a>
</div>

An SBOM is a JSON file. Without cryptographic signing, anyone with write access can remove a vulnerable component, change a version number, or delete an entire dependency tree. The modified SBOM passes schema validation and compliance checks without raising an alert. NIST SP 800-218 (SSDF) control PW.4.1 explicitly requires verifying SBOM integrity, recognizing that an unprotected SBOM is no better than no SBOM at all.

### Attack Flow

```mermaid
graph LR
    A[Take SBOM] --> B[Remove vuln entry]
    B --> C[Feed to compliance tool]
    C --> D[Reports clean]
    D --> E[Vuln still exists]
```

## Environment

| Service | Address | Description |
|---------|---------|-------------|
| Workstation | `weaklink-ws` | Has syft, grype, cosign, jq, and a Python application |
| Registry | `registry:5000` | Local registry with images and attached SBOMs |

!!! tip "Related Labs"
    - **Prerequisite:** [4.1 What SBOMs Actually Contain](../4.1-sbom-contents/index.md) — Understanding SBOM contents before tampering with them
    - **Prerequisite:** [4.3 Signing Fundamentals](../4.3-signing-fundamentals/index.md) — Signing is the primary defense against SBOM tampering
    - **See also:** [4.2 SBOM Gaps in Practice](../4.2-sbom-gaps/index.md) — SBOM gaps and tampering both undermine dependency visibility
    - **See also:** [1.4 Lockfile Injection](../../tier-1/1.4-lockfile-injection/index.md) — Lockfile injection is a similar metadata integrity attack
