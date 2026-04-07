# Lab 6.6: Case Study. SolarWinds (SUNBURST)

<div class="lab-meta">
  <span>Understand: ~10 min | Analyze: ~10 min | Lessons: ~10 min | Detect: ~5 min</span>
  <span class="difficulty advanced">Advanced</span>
  <span>Prerequisites: <a href="../../tier-2/2.2-direct-ppe/">Lab 2.2</a></span>
</div>

In December 2020, Russian intelligence (SVR/APT29) compromised SolarWinds' Orion build system and injected a backdoor, dubbed SUNBURST, into a legitimate software update. The update was digitally signed by SolarWinds and distributed to approximately 18,000 customers, including the U.S. Treasury, Commerce Department, DHS, and Fortune 500 companies. The backdoor was injected into the build process (not the source code), lay dormant for two weeks, communicated via DNS mimicking legitimate traffic, and avoided activating on security company systems.

### Attack Flow

```mermaid
graph LR
    A[Attackers access<br>build system] --> B[Inject code during<br>compilation]
    B --> C[Signed Orion<br>update ships]
    C --> D[18,000 orgs<br>install update]
    D --> E[SUNBURST C2<br>activates after 14d]
    E --> F[Espionage on<br>high-value targets]
```

## Environment

| Component | Path | Description |
|-----------|------|-------------|
| Build Simulation | `/app/build-system/` | Simulated build pipeline demonstrating the injection technique |
| SUNBURST Analysis | `/app/sunburst/` | Annotated code samples from the SUNBURST implant |
| Detection Tools | `/app/detection/` | Scripts for detecting SUNBURST-style build compromises |
| Defense Templates | `/app/defenses/` | Build verification and provenance templates |

<div class="phase-stepper">
  <span class="phase-step current">Overview</span>
  <span class="phase-arrow">›</span>
  <a href="understand/" class="phase-step upcoming">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="analyze/" class="phase-step upcoming">Analyze</a>
  <span class="phase-arrow">›</span>
  <a href="lessons/" class="phase-step upcoming">Lessons</a>
  <span class="phase-arrow">›</span>
  <a href="detect/" class="phase-step upcoming">Detect</a>
</div>

!!! tip "Related Labs"
    - **Prerequisite:** [2.2 Direct Poisoned Pipeline Execution](../../tier-2/2.2-direct-ppe/index.md) — Direct PPE shows how build pipelines can be compromised
    - **See also:** [6.5 Case Study: xz-utils (CVE-2024-3094)](../6.5-case-study-xz-utils/index.md) — xz-utils is another build-system compromise by a trusted insider
    - **See also:** [4.4 Attestation & Provenance (SLSA)](../../tier-4/4.4-attestation-slsa/index.md) — Attestation would have helped detect the tampered build
    - **See also:** [7.1 Building Detection Rules](../../tier-7/7.1-detection-rules/index.md) — Detection rules for build-system compromise apply here
