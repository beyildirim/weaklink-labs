# Lab 4.4: Attestation & Provenance (SLSA)

<div class="lab-meta">
  <span>~20 min hands-on | ~15 min reference</span>
  <span class="difficulty intermediate">Intermediate</span>
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

Signing proves who approved an artifact. Attestation proves where it came from. Build provenance answers: "Was this built by trusted CI from reviewed source, or did someone build it on their laptop and push it?"

### Attack Flow

```mermaid
graph LR
    A[CI builds artifact] --> B[Generates provenance]
    B --> C[Signs with Sigstore]
    C --> D[Verifier checks before deploy]
```

## Environment

| Service | Address | Description |
|---------|---------|-------------|
| Workstation | `weaklink-ws` | Has cosign, crane, slsa-verifier, jq |
| Registry | `registry:5000` | Contains images with and without provenance attestations |
| Kubernetes | `kind-cluster` | Local cluster for deployment testing |
