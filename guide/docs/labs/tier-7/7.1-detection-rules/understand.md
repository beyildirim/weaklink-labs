# Lab 7.1: Building Detection Rules for Supply Chain Attacks

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../investigate/" class="phase-step upcoming">Investigate</a>
  <span class="phase-arrow">›</span>
  <a href="../validate/" class="phase-step upcoming">Validate</a>
  <span class="phase-arrow">›</span>
  <a href="../improve/" class="phase-step upcoming">Improve</a>
</div>

**Goal:** Identify the log sources that matter and what each source can and cannot see.

## Step 1: Map the telemetry sources

| Log Source | What It Captures | Attack Types Detected |
|------------|-----------------|----------------------|
| **CI/CD logs** (GitHub Actions, GitLab CI) | Build commands, dependency installs, script execution | Lockfile injection, manifest confusion, phantom deps |
| **Package manager logs** (pip, npm verbose output) | Package resolution, version selection, registry source | Dependency confusion, typosquatting |
| **Proxy / DNS logs** (Squid, Zscaler, corporate DNS) | Outbound connections from build servers | Exfiltration from malicious setup.py / install scripts |
| **Container registry audit logs** | Image pulls, tag resolution, digest mismatches | Tag mutability, base image poisoning |
| **EDR process telemetry** | Process trees, file writes, network connections per process | All attack types (post-execution indicators) |
| **Git audit logs** | Commit signatures, PR approval state, force pushes | Lockfile injection, manifest confusion |

## Step 2: Understand the detection timeline

```
Timeline of a dependency confusion attack:

  t=0     Developer pushes requirements.txt with loose pin
  t=1     CI pipeline triggers pip install
  t=2     pip queries public PyPI (DETECTABLE: proxy logs)
  t=3     pip downloads malicious package (DETECTABLE: proxy logs, network)
  t=4     setup.py executes (DETECTABLE: EDR process tree)
  t=5     Exfiltration begins (DETECTABLE: firewall, DNS, proxy)
  t=6     Build completes, artifact published
  t=7     Artifact deployed to production (DETECTABLE: runtime monitoring)

  Detection windows:
  [t=2 to t=5] = minutes       (SOC can catch this in near real-time)
  [t=5 to t=7] = minutes-hours (containment still possible)
  [t=7+]       = too late      (attacker has persistent access)
```

Your rules must fire between t=2 and t=5.

## Step 3: MITRE ATT&CK mapping

| Technique | ID | Attack Types |
|-----------|-----|-------------|
| Supply Chain Compromise: Software Dependencies | [T1195.001](https://attack.mitre.org/techniques/T1195/001/) | Typosquatting, phantom dependencies |
| Supply Chain Compromise: Software Supply Chain | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Dependency confusion, lockfile injection, manifest confusion |
| Command and Scripting Interpreter: Python | [T1059.006](https://attack.mitre.org/techniques/T1059/006/) | Malicious setup.py execution |
| Automated Exfiltration | [T1020](https://attack.mitre.org/techniques/T1020/) | Data theft during pip install |
| Application Layer Protocol: Web Protocols | [T1071.001](https://attack.mitre.org/techniques/T1071/001/) | C2 / exfiltration over HTTP/HTTPS |
