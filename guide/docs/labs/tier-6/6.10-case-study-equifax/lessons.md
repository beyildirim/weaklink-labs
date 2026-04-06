# Lab 6.10: Case Study. Equifax Breach (CVE-2017-5638)

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../analyze/" class="phase-step done">Analyze</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Lessons</span>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Building a Patching Process That Works

**Goal:** Implement controls that prevent remediation failures.

### Lesson 1: Patching SLAs with escalation

```bash
cat /app/patch-compliance-checklist.md
```

- **Critical (CVSS 9.0-10.0):** 48-hour SLA, CISO escalation at 24 hours
- **High (CVSS 7.0-8.9):** 7-day SLA, manager escalation at 5 days
- **Medium:** 30-day SLA
- **Low:** 90-day SLA

CVE-2017-5638 (CVSS 10.0) would have required a 48-hour patch with CISO notification at 24 hours.

### Lesson 2: Scanning without remediation workflow is theater

Equifax scanned, found the CVE, sent an email. Nobody followed up. A complete program requires: SCAN, TICKET (auto-create), ASSIGN (route to owner), TRACK (SLA clock), PATCH, VERIFY (rescan), ESCALATE (auto-escalate on SLA breach). Equifax only did step 1.

### Lesson 3: Compensating controls buy time

```bash
cat /app/waf-rules.conf
```

ModSecurity rules blocking OGNL expressions in Content-Type headers. If deployed on March 8, the May 13 exploit attempts would have been blocked. Deploy WAF rules immediately on critical Struts CVE publication, before patching completes.

### Lesson 4: Dependency monitoring with SLAs

```bash
cat /app/dependency-monitor.yml
```

Automated scanning with ticket creation, owner assignment, SLA tracking, and escalation at 12, 24, and 36 hours for critical CVEs. The configuration maps `struts2-core` to a `critical_48h` SLA with automatic escalation to team lead, VP Engineering, and CISO.

### Verify understanding

```bash
weaklink verify 6.10
```
