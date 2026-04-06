# Lab 4.6: Attestation Forgery

<div class="lab-meta">
  <span>~25 min hands-on | ~15 min reference</span>
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
