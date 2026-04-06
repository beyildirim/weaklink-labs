# Lab 2.6: GitHub Actions Injection

<div class="lab-meta">
  <span>~15 min hands-on | ~15 min reference</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: <a href="../2.2-direct-ppe/">Lab 2.2</a></span>
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

`${{ }}` expressions interpolate user-controlled inputs directly into shell commands. An attacker who controls an issue title, PR branch name, commit message, or comment body can inject arbitrary shell commands into the CI pipeline without modifying any workflow file. The workflow YAML stays on the default branch; the vulnerability is in how it uses expressions. When `${{ github.event.issue.title }}` appears inside a `run:` block, GitHub Actions performs string interpolation *before* the shell sees it. `github/codeql-action`, `microsoft/vscode`, and hundreds of others were found vulnerable.

### Attack Flow

```mermaid
graph LR
    A[User creates issue] --> B[Title contains payload]
    B --> C[Workflow interpolates title in run:]
    C --> D[Shell injection]
    D --> E[RCE]
```

## Environment

| Service | Address | Description |
|---------|---------|-------------|
| Gitea | `gitea:3000` | Git server hosting `wl-webapp` with Actions workflows |
| Workstation | (your shell) | Development environment |
