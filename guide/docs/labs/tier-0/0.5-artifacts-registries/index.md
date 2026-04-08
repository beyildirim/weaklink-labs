# Lab 0.5: Artifacts & Registries

<div class="lab-meta">
  <span>Understand: ~8 min | Break: ~8 min | Defend: ~9 min | Detect: ~5 min</span>
  <span class="difficulty beginner">Beginner</span>
  <span>Prerequisites: <a href="../../tier-0/0.2-package-managers/">Lab 0.2</a></span>
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

Once source code is built, it is packaged into an artifact (Python wheel, npm tarball, Docker image) and uploaded to a **registry**. Other developers and systems download these artifacts. Relying on version numbers without cryptographic hashes is dangerous because artifacts can be silently replaced. In 2021, attackers compromised Codecov's bash uploader artifact and replaced it with a backdoored version that exfiltrated CI environment variables for over two months before detection.

### Attack Flow

```mermaid
graph LR
    A[Developer publishes v1.0.0] -->|Artifact on registry| B[Others install v1.0.0]
    B -->|Attacker gains registry access| C[Replaces v1.0.0 with backdoored artifact]
    C -->|Same version number| D[Developer installs v1.0.0 again]
    D --> E[Gets backdoored code, hash mismatch undetected]
```

## Environment

| Service | Address |
|---------|---------|
| PyPI Private | `http://pypi-private:8080` |
| Verdaccio | `http://verdaccio:4873` |
| OCI Registry | `http://registry:5000` |

!!! tip "Related Labs"
    - **Prerequisite:** [0.2 How Package Managers Work](../0.2-package-managers/index.md) — Registries host the packages that package managers install
    - **Prerequisite:** [0.3 How Containers Work](../0.3-containers/index.md) — Container registries store the images you build
    - **Next:** [3.4 Registry Confusion](../../tier-3/3.4-registry-confusion/index.md) — What happens when registry resolution is ambiguous
    - **See also:** [1.2 Dependency Confusion](../../tier-1/1.2-dependency-confusion/index.md) — Dependency confusion exploits how registries are prioritized
