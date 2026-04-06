# Lab 6.10: Case Study. Equifax Breach (CVE-2017-5638)

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

## The Timeline of a Preventable Breach

**Goal:** Understand how every step of the remediation process failed.

### The timeline

| Date | Event |
|------|-------|
| 2017-03-07 | Apache releases Struts 2.3.32, patching CVE-2017-5638 |
| 2017-03-08 | Public exploit code available; attacks in the wild |
| 2017-03-15 | Equifax's scanner identifies vulnerable Struts; notification sent |
| ??? | **No patch applied. No follow-up. No escalation.** |
| 2017-05-13 | Attackers exploit the unpatched vulnerability |
| 2017-07-29 | Breach discovered (78 days later) |
| 2017-09-07 | Public disclosure |
| 2019-07-22 | **$700 million settlement** |

### The vulnerability

```bash
cat /app/analysis/cve-2017-5638-detail.txt
```

CVE-2017-5638: RCE in the Jakarta Multipart parser. A malformed Content-Type header triggers exception handling that **evaluates OGNL expressions**. Full shell access. No authentication required.

### The dependency was visible

```bash
cat /app/pom.xml
grep -A2 "struts" /app/pom.xml
```

Unlike Log4Shell, Struts was a **direct dependency** listed in the `pom.xml`. The version number was right there.

```bash
cat /app/analysis/vulnerability-report.txt
cat /app/analysis/patch-timeline.txt
```

Compare the scanner detection date (March 15) against the patch availability date (March 7) and the exploitation date (May 13). The gap between detection and remediation is 59 days.

### Why the patch was not applied

The US House Committee investigation identified:

1. **Email notification sent, not tracked.** Nobody confirmed receipt or tracked remediation.
2. **No ownership mapping.** Nobody mapped vulnerable applications to owning teams.
3. **Scanner found it, nobody acted.** Scan result went into a queue with no assignee and no SLA.
4. **No verification loop.** Nobody checked if the patch was applied.
5. **Expired SSL certificate on inspection tool.** Network traffic inspection had an expired cert for **19 months**. Encrypted exfiltration passed uninspected.
6. **No network segmentation.** The dispute portal had direct access to backend databases.
