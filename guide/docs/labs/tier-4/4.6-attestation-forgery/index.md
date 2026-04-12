# Lab 4.6: Attestation Forgery

<div class="lab-meta">
  <span>Understand: ~8 min | Break: ~8 min | Defend: ~9 min | Detect: ~15 min</span>
  <span class="difficulty advanced">Advanced</span>
  <span>Prerequisites: <a href="../4.4-attestation-slsa/">Lab 4.4</a></span>
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

If an attacker controls the signing key, they control the attestation. They can generate a valid in-toto attestation claiming "built by GitHub Actions from main branch" for an image they built on their laptop with a backdoor.

This lab puts you in the attacker's seat: forge an attestation, pass verification, then learn how keyless signing and transparency logs make forgery detectable.

### Attack Flow

```mermaid
graph LR
    A[Attacker generates key] --> B[Signs forged attestation]
    B --> C[Verification passes]
    C --> D[Malicious artifact trusted]
```

## Environment

| Service | Address | Description |
|---------|---------|-------------|
| Workstation | `weaklink-ws` | Has cosign, slsa-verifier, in-toto, rekor-cli, jq |
| Registry | `registry:5000` | Contains images with real and forged attestations |

> **Related Labs**
>
> - **Prerequisite:** [4.4 Attestation & Provenance (SLSA)](../4.4-attestation-slsa/index.md) — Understanding attestation before forging it
> - **See also:** [4.5 Signature Bypass Attacks](../4.5-signature-bypass/index.md) — Both attack the verification layer that protects artifacts
> - **See also:** [6.6 Case Study: SolarWinds (SUNBURST)](../../tier-6/6.6-case-study-solarwinds/index.md) — SolarWinds effectively forged build provenance
