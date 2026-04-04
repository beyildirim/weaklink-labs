# SolarWinds SUNBURST — Attack Timeline

| Date | Event |
|------|-------|
| 2019-10 | Attackers gain access to SolarWinds build system |
| 2020-02 | SUNBURST backdoor injected into Orion build pipeline |
| 2020-03 | Backdoored Orion update (2019.4 HF 5 through 2020.2.1) shipped to ~18,000 customers |
| 2020-12-08 | FireEye discovers breach via stolen red team tools |
| 2020-12-13 | SolarWinds advisory published |

## Key Insight
The build system itself was compromised. The source code was clean —
the backdoor was injected during compilation, making code review useless.
