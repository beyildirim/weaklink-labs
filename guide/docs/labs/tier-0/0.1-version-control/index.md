# Lab 0.1: How Version Control Works

<div class="lab-meta">
  <span>Understand: ~7 min | Break: ~7 min | Defend: ~6 min | Detect: ~5 min</span>
  <span class="difficulty beginner">Beginner</span>
  <span>Prerequisites: None</span>
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

Version control (Git) is the foundation of every software supply chain. Every piece of code, configuration change, and build script lives in a Git repository. Compromise what goes into a repo and you control what gets built and deployed.

### Attack Flow

```mermaid
graph LR
    A[Developer pushes code] -->|Includes build.sh change| B[Malicious line hidden in commit]
    B -->|Commit message lies| C[CI runs build.sh]
    C -->|setup.py executes| D[Secrets exfiltrated to /tmp]
    D -->|No review required| E[Attacker has credentials]
```

## Environment

| Service     | Address                             |
|-------------|-------------------------------------|
| Gitea UI    | `gitea:3000`                        |
| Login       | `weaklink` / `weaklink`     |
| Repository  | `weaklink/web-app`                  |
