# Lab 4.5: Signature Bypass Attacks

<div class="lab-meta">
  <span>~20 min hands-on | ~15 min reference</span>
  <span class="difficulty advanced">Advanced</span>
  <span>Prerequisites: <a href="../4.3-signing-fundamentals/">Lab 4.3</a></span>
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

Signing is only useful if verification is enforced, the right key is checked, and old signatures can't be replayed. This lab demonstrates three bypass techniques that defeat signing in practice.

### Attack Flow

```mermaid
graph LR
    A[Push unsigned artifact] --> B[Verification not enforced]
    B --> C[Deployed without integrity check]
```

## Environment

| Service | Address | Description |
|---------|---------|-------------|
| Workstation | `weaklink-ws` | Has cosign, crane, kubectl, and two key pairs (trusted + attacker) |
| Registry | `registry:5000` | Contains signed, unsigned, and attacker-signed images |
| Kubernetes | `kind-cluster` | Local cluster with optional policy controller |

!!! tip "Related Labs"
    - **Prerequisite:** [4.3 Signing Fundamentals](../4.3-signing-fundamentals/index.md) — Understanding signatures before learning to bypass them
    - **Next:** [4.6 Attestation Forgery](../4.6-attestation-forgery/index.md) — Attestation forgery extends bypass attacks to provenance
    - **See also:** [4.7 SBOM Tampering](../4.7-sbom-tampering/index.md) — SBOM tampering bypasses integrity checks on metadata
    - **See also:** [5.5 Kubernetes Admission Controller Bypass](../../tier-5/5.5-admission-controller-bypass/index.md) — Admission controller bypass defeats signature enforcement
