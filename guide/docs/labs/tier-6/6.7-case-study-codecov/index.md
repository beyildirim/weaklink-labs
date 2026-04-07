# Lab 6.7: Case Study. Codecov Bash Uploader

<div class="lab-meta">
  <span>Understand: ~8 min | Analyze: ~7 min | Lessons: ~10 min | Detect: ~5 min</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: <a href="../../tier-2/2.4-secret-exfiltration/">Lab 2.4</a></span>
</div>

On April 1, 2021, Codecov disclosed that their Bash Uploader script, used by thousands of CI/CD pipelines, had been modified by an attacker. The compromised script exfiltrated every environment variable from the CI runner: AWS keys, GitHub tokens, Docker registry credentials, database passwords. The attack persisted undetected for over two months. The canonical example of why `curl | bash` is dangerous in CI/CD.

### Attack Flow

```mermaid
graph LR
    A[Attacker modifies<br>Bash Uploader<br>on codecov.io] --> B[CI pipelines<br>curl and execute]
    B --> C[Env vars POSTed<br>to attacker server]
    C --> D[AWS keys, tokens,<br>passwords stolen]
    D --> E[Downstream repos<br>and cloud access<br>compromised]
```

## Environment

| Component | Path | Description |
|-----------|------|-------------|
| CI Pipeline | `/app/ci-pipeline/` | Simulated GitHub Actions workflow using Codecov uploader |
| Uploader Scripts | `/app/uploader/` | Legitimate and compromised versions of the Bash uploader |
| Exfil Server | `exfil-server:8080` | Simulated attacker server receiving exfiltrated variables |
| Defense Templates | `/app/defenses/` | Pinned and verified script alternatives |

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
    - **Prerequisite:** [2.4 Secret Exfiltration from CI](../../tier-2/2.4-secret-exfiltration/index.md) — Secret exfiltration from CI is exactly what Codecov enabled
    - **See also:** [2.6 GitHub Actions Injection](../../tier-2/2.6-actions-injection/index.md) — The Codecov attack injected code into a widely-used CI script
    - **See also:** [6.6 Case Study: SolarWinds (SUNBURST)](../6.6-case-study-solarwinds/index.md) — Both SolarWinds and Codecov compromised widely-trusted CI tooling
    - **See also:** [7.2 Supply Chain Incident Triage](../../tier-7/7.2-incident-triage/index.md) — Incident triage for supply chain breaches like Codecov
