# Lab 6.6: Case Study: SolarWinds (SUNBURST)

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Analyze</span>
  <span class="phase-arrow">›</span>
  <a href="../lessons/" class="phase-step upcoming">Lessons</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## The SUNBURST Implant

**Goal:** Walk through how SUNBURST operated: dormancy, C2 communication, and anti-analysis techniques.

### The dormancy period

```bash
cat /app/sunburst/dormancy-annotated.cs
```

SUNBURST waited **12-14 days** before activating. It checked the system clock, domain membership, running processes (aborted if security tools were running), and network configuration. This evaded sandbox analysis, which runs samples for minutes to hours.

### DNS-based C2

```bash
cat /app/sunburst/c2-communication-annotated.cs
```

C2 via DNS queries to `avsvmcloud[.]com`. Subdomains encoded victim data and mimicked AWS API endpoints, making them difficult to distinguish from legitimate SolarWinds cloud traffic.

### Anti-analysis and evasion

```bash
cat /app/sunburst/evasion-annotated.cs
```

Process blocklist (Wireshark, Fiddler, ProcMon), domain blocklist ("test", "solarwinds", "lab", security company names), FNV-1a hash obfuscation for string comparison, legitimate-looking API traffic for C2, steganographic encoding in HTTP responses.

### Why traditional controls failed

Every control failed:

- Code review: backdoor was in the build, not the source
- Signing: SolarWinds' own certificate signed the backdoored DLL
- Antivirus: zero known signatures
- Network monitoring: traffic mimicked legitimate DNS
- Sandbox: 12-day dormancy
- Update channel: distributed via official SolarWinds server

> **Checkpoint:** You should understand why the build system (not source code) was the target, and why code signing provided zero protection. Verify by examining the diff between legitimate and compromised build scripts.
