# Lab 6.6: Case Study: SolarWinds (SUNBURST)

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../analyze/" class="phase-step upcoming">Analyze</a>
  <span class="phase-arrow">›</span>
  <a href="../lessons/" class="phase-step upcoming">Lessons</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## The SolarWinds Orion Build Compromise

**Goal:** Study how attackers injected code into compiled DLLs that source review would not detect.

### The timeline

| Date | Event |
|------|-------|
| 2019-10 (est.) | Attackers gain initial access to SolarWinds network |
| 2020-02 | SUNBURST code injected into Orion build process |
| 2020-03-26 | First trojanized Orion update ships (2019.4 HF5) |
| 2020-06 | Orion 2020.2 also contains SUNBURST |
| 2020-12-08 | FireEye discloses breach and stolen red team tools |
| 2020-12-13 | SolarWinds confirms supply chain compromise |
| 2020-12-15 | Kill switch activated (Microsoft, FireEye, GoDaddy sinkhole C2 domain) |

### The build system as the target

```bash
cat /app/analysis/build-compromise.txt
```

The attackers did NOT modify source code in version control. They compromised the build pipeline to inject code into `SolarWinds.Orion.Core.BusinessLayer.dll` during compilation. Source code review showed nothing. Code diffs showed no backdoor. SolarWinds' own code signing certificate was applied to the backdoored DLL.

### Find the injection point in the build pipeline

```bash
cat /app/build-system/compromised-build.sh
grep -n "COMPILE\|inject\|tmp\|additional" /app/build-system/compromised-build.sh
```

Look for the unsigned or injected step. The attacker added an MSBuild step that compiles an extra `.cs` file from a temp directory. This step has no code review gate, no signature verification, and no audit trail.

### Compare the legitimate and compromised builds

```bash
diff /app/build-system/legitimate-build.sh /app/build-system/compromised-build.sh
```

The attackers added an MSBuild step that compiled an additional `.cs` file containing SUNBURST code. The file was placed in a temporary directory during build and removed afterward.

### Why signing did not help

**Signing proves who built it, not whether the build process was compromised.** SolarWinds digitally signed the backdoored DLL with their Authenticode certificate. From the customer's perspective, the update was legitimate.
