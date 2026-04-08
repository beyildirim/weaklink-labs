# Lab 6.10: Case Study: Equifax Breach (CVE-2017-5638)

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

## The Attack and 78-Day Breach

**Goal:** Walk through CVE-2017-5638 exploitation and how attackers operated undetected.

### OGNL injection via Content-Type

When the Jakarta Multipart parser encounters a malformed Content-Type, it constructs an error message including the header value. The error message is processed through OGNL evaluation: arbitrary expressions execute as code.

The OGNL exploit payload overrides Struts security restrictions, clears the excluded packages list, creates a ProcessBuilder for shell commands, and pipes output through the HTTP response.

```http
POST /dispute HTTP/1.1
Content-Type: %{(#_='multipart/form-data').(#dm=@ognl.OgnlContext@DEFAULT_MEMBER_ACCESS)....(#cmd='whoami').(#p=new java.lang.ProcessBuilder(#cmds))...}
```

### What the attackers did

Based on forensics:

1. **Initial access (May 13):** Exploited CVE-2017-5638 for shell access
2. **Credential theft:** Found database passwords in plaintext in application config
3. **Lateral movement:** Unrestricted network access from web server to database servers
4. **Data exfiltration:** ~9,000 database queries over 78 days, small batches to avoid volume alerts
5. **Encrypted exfiltration:** SSL inspection device had expired cert; encrypted traffic passed uninspected

### The scope

147 million Americans: names, SSNs (145.5M), birth dates (99M), addresses, driver's license numbers, 209,000 credit card numbers. Approximately 56% of all American adults.

> **Checkpoint:** You should understand the full chain: known CVE, scanner detection, notification failure, exploitation, 78-day dwell time. Verify by examining the `pom.xml` to confirm the vulnerable Struts version (2.3.31).
