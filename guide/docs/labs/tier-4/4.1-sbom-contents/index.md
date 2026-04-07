# Lab 4.1: What SBOMs Actually Contain

<div class="lab-meta">
  <span>Phase 1 ~10min | Phase 2 ~10min | Phase 3 ~10min</span>
  <span class="difficulty beginner">Beginner</span>
  <span>Prerequisites: <a href="../../tier-1/1.1-dependency-resolution.md">Lab 1.1</a></span>
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

After Log4Shell (CVE-2021-44228), the US government mandated SBOMs for any software sold to federal agencies (Executive Order 14028). An SBOM is supposed to be a complete ingredient list for your software. But what does an SBOM actually contain, and more importantly, what does it miss? In this lab you generate SBOMs in two industry-standard formats and discover their blind spots firsthand.

### Attack Flow

```mermaid
graph LR
    A[Generate SBOM] --> B[Lists direct deps]
    B --> C[Misses vendored code]
    C --> D[False sense of completeness]
```

## Environment

| Service | Address | Description |
|---------|---------|-------------|
| Workstation | `weaklink-ws` | Has syft, cdxgen, and a Python app with vendored C code |
| Registry | `registry:5000` | Local container registry with pre-built images |

!!! tip "Related Labs"
    - **Prerequisite:** [1.1 How Dependency Resolution Works](../../tier-1/1.1-dependency-resolution/index.md) — Understanding dependency resolution is essential before tracking deps in SBOMs
    - **Next:** [4.2 SBOM Gaps in Practice](../4.2-sbom-gaps/index.md) — Exploring what SBOMs miss in practice
    - **See also:** [4.7 SBOM Tampering](../4.7-sbom-tampering/index.md) — SBOM tampering attacks the integrity of what you learn here
    - **See also:** [8.2 SSDF / NIST SP 800-218 Mapping](../../tier-8/8.2-ssdf-nist/index.md) — SSDF/NIST requires SBOM generation as a compliance control
