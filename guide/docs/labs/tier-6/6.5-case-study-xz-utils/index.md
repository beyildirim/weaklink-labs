# Lab 6.5: Case Study: xz-utils (CVE-2024-3094)

<div class="lab-meta">
  <span>Understand: ~10 min | Analyze: ~10 min | Lessons: ~10 min | Detect: ~5 min</span>
  <span class="difficulty advanced">Advanced</span>
  <span>Prerequisites: <a href="../../tier-2/2.3-indirect-ppe/">Lab 2.3</a></span>
</div>

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

On March 29, 2024, Andres Freund noticed SSH logins taking ~500ms longer than usual. His investigation uncovered the most sophisticated open source supply chain attack ever documented: a backdoor in xz-utils giving the attacker remote code execution through SSH. The attack was a **two-year social engineering campaign** targeting a burned-out sole maintainer. The attacker, "Jia Tan," built trust, took over maintenance, and injected a backdoor into the build system that was invisible in the source code.

### Attack Flow

```mermaid
graph LR
    A[Jia Tan gains trust<br>over 2 years] --> B[Becomes xz-utils<br>co-maintainer]
    B --> C[Modifies<br>build-to-host.m4]
    C --> D[Backdoor injected<br>into liblzma]
    D --> E[Targets SSH auth<br>via IFUNC hook]
    E --> F[RCE on affected<br>Linux systems]
```

## Environment

| Component | Path | Description |
|-----------|------|-------------|
| Attack Timeline | `/app/timeline/attack-timeline.md` | Chronology of the maintainer takeover and release timeline |
| Detection Notes | `/app/indicators/iocs.txt` | IOC-style notes for the affected versions and release artifacts |
| Learner Outputs | `/app/analysis.md`, `/app/detect_xz_backdoor.sh`, `/app/check_reproducible.sh` | Files you create during the case study |

This case-study lab is lighter on seeded infrastructure than the core attack path. The main outputs are your own analysis notes plus two small helper scripts checked by the lab verifier.
