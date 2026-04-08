# Lab 1.4: Lockfile Injection

<div class="lab-meta">
  <span>Understand: ~8 min | Break: ~8 min | Defend: ~9 min | Detect: ~10 min</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: <a href="../../tier-1/1.1-dependency-resolution/">Lab 1.1</a></span>
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

A PR titled "chore: update flask-utils to latest version" only changes the lockfile. Auto-generated, thousands of lines, nobody reads it carefully. But hidden in the diff, one hash has been swapped. The new hash points to a backdoored package.

### Attack Flow

```mermaid
graph LR
    A[Attacker submits PR] --> B[Only lockfile changed]
    B --> C[Reviewer skips diff]
    C --> D[CI installs from tampered lockfile]
    D --> E[Backdoor runs]
```

## Environment

| Service | Address | Description |
|---------|---------|-------------|
| PyPI | `pypi-private:8080` | A private PyPI server hosting the legitimate `flask-utils` package |
| Gitea | `gitea:3000` | A Gitea instance with a repo containing a malicious PR |

Login: `weaklink` / `weaklink`
