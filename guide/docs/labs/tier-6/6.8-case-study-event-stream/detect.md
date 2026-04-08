# Lab 6.8: Case Study: event-stream / ua-parser-js

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../analyze/" class="phase-step done">Analyze</a>
  <span class="phase-arrow">›</span>
  <a href="../lessons/" class="phase-step done">Lessons</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Detect</span>
</div>

<div class="no-terminal-notice">Reference material. No terminal needed.</div>

## Identifying Maintainer Takeover and Malicious Updates

Two signal categories: **package metadata changes** (new maintainer, new dependency, unusual version) and **runtime indicators** (install scripts downloading binaries, outbound connections during `npm install`, mining processes).

**Key indicators:**

- npm package maintainer changes in your dependency tree
- New transitive dependencies in `package-lock.json` without `package.json` changes
- Install scripts in packages that previously lacked them
- `npm install` spawning child processes (curl, wget, powershell)
- Cryptocurrency mining connections from developer workstations

| Indicator | What It Means |
|-----------|---------------|
| Maintainer change in monitored package | Social engineering or account takeover |
| New transitive dep without direct dep change | Dependency injection via existing package |
| `npm install` spawning network process | Malicious preinstall or postinstall script |

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Both attacks compromised npm registry packages |
| **Trusted Relationship** | [T1199](https://attack.mitre.org/techniques/T1199/) | event-stream: social engineering for maintainer access |
| **Valid Accounts** | [T1078](https://attack.mitre.org/techniques/T1078/) | ua-parser-js: compromised npm credentials |
| **Resource Hijacking** | [T1496](https://attack.mitre.org/techniques/T1496/) | ua-parser-js: cryptocurrency miners |

**Alerts:** "npm install spawned unexpected child process" (EDR), "Cryptocurrency mining connection" (network), "npm package maintainer change detected" (registry monitoring), "New transitive dependency without package.json change" (CI check).

event-stream (social engineering) is harder to detect: obfuscated, targeted. ua-parser-js (account hijack) is noisier but has immediate mass impact.

**Triage steps:**

1. Check if the package is in your tree (direct or transitive)
2. Check version against known-bad advisories
3. Check if `npm install` ran during the exposure window
4. Look for mining processes or unusual outbound connections
5. Update to clean version and rotate exposed credentials

---

## What You Learned

- **Maintainer accounts are the master key.** A single compromised or transferred npm account affects every downstream consumer.
- **Targeted payloads evade detection.** The event-stream backdoor only activated in Copay, invisible to automated scanning.
- **Lockfile review catches dependency injection.** The addition of `flatmap-stream` would have been visible as an unexplained new entry.

## Further Reading

- [Dominic Tarr's Statement on event-stream](https://gist.github.com/dominictarr/9fd9c1024c94592bc7268d36b8d83b3a)
- [GitHub Advisory: flatmap-stream (GHSA-7fhm-mqm4-2wp7)](https://github.com/advisories/GHSA-7fhm-mqm4-2wp7)
- [CISA: ua-parser-js Compromise](https://www.cisa.gov/news-events/alerts/2021/10/22/malware-discovered-popular-npm-package-ua-parser-js)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
