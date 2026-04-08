# Lab 4.3: Signing Fundamentals

<div class="lab-meta">
  <span>Understand: ~10 min | Break: ~8 min | Defend: ~12 min | Detect: ~5 min</span>
  <span class="difficulty beginner">Beginner</span>
  <span>Prerequisites: <a href="../../tier-0/0.3-containers.md">Lab 0.3</a></span>
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

The SolarWinds attack succeeded because Orion updates were unsigned, or more precisely, the build system's signing was compromised. Without cryptographic signing, there is no way to verify that an artifact was built by the right system from the right source. In this lab you deploy an unsigned container image, see that Kubernetes accepts it without complaint, then sign an image with cosign and create a policy that rejects anything unsigned.

### Attack Flow

```mermaid
graph LR
    A[Artifact pushed unsigned] --> B[No verification]
    B --> C[Deployed]
    C --> D[Could be tampered]
```

## Environment

| Service | Address | Description |
|---------|---------|-------------|
| Workstation | `weaklink-ws` | Has cosign, crane, and kubectl installed |
| Registry | `registry:5000` | Local registry with signed and unsigned images |
| Kubernetes | `kind-cluster` | Local cluster for deployment testing |
