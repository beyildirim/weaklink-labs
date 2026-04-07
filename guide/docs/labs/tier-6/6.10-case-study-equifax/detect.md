# Lab 6.10: Case Study. Equifax Breach (CVE-2017-5638)

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

## Identifying Struts Exploitation and Unpatched Instances

Struts exploitation produces clear signatures: **OGNL expressions in Content-Type headers** and **command output in HTTP responses**. Post-exploitation generates database query volume anomalies and data exfiltration patterns.

**Key indicators:**

- OGNL expressions in Content-Type headers
- Web servers making unusual database queries (volume or pattern change)
- Large data transfers from web servers to external destinations
- Java/Tomcat spawning shell processes
- Unpatched Struts instances past SLA

| Indicator | Description |
|-----------|-------------|
| Java/Tomcat spawning `sh`, `bash`, `cmd.exe` | Post-exploitation command execution |
| OGNL keywords in Content-Type header | CVE-2017-5638 exploit attempt |
| Web server querying database at unusual rate | Data exfiltration phase |
| Large outbound transfers from DMZ | Exfiltration of stolen data |

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Exploit Public-Facing Application** | [T1190](https://attack.mitre.org/techniques/T1190/) | RCE via malformed Content-Type on internet-facing portal |
| **Supply Chain Compromise: Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Failure to patch a known vulnerability in a third-party framework |

**Alerts:** "OGNL expression in Content-Type" (WAF/IDS), "Java process spawned shell" (EDR), "Anomalous database query volume" (SIEM), "Unpatched CVE-2017-5638 detected" (vuln management), "Large outbound transfer from DMZ" (DLP).

The SOC's role extends beyond detecting exploitation. It includes monitoring **patch compliance**. If your SOC tracks vulnerability scan results and alerts when critical CVEs remain unpatched past SLA, the Equifax scenario cannot happen.

**Triage steps:**

1. Check for CVE-2017-5638 signature firing in WAF/IDS
2. Identify all Struts instances via asset inventory
3. Verify patch status (2.3.32+ or 2.5.10.1+)
4. If unpatched: deploy WAF rules immediately and restrict database access
5. If exploited: isolate, check for web shells, audit database logs, check for exfiltration

---

### CI Integration

Add this workflow to enforce vulnerability scanning with SLA-based blocking. Save as `.github/workflows/vuln-sla-check.yml`:

```yaml
name: Vulnerability SLA Enforcement

on:
  pull_request:
  push:
    branches: [main]
  schedule:
    - cron: "0 6 * * *"  # Daily scan

permissions:
  contents: read

jobs:
  check-vulnerability-sla:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Run vulnerability scan
        run: |
          pip install pip-audit 2>/dev/null || true
          EXIT_CODE=0
          if [ -f requirements.txt ]; then
            echo "--- Scanning Python dependencies ---"
            if pip-audit -r requirements.txt --desc 2>/dev/null; then
              echo "PASS: No known vulnerabilities found."
            else
              echo "::error::Known vulnerabilities detected in dependencies."
              echo ""
              echo "The Equifax breach was caused by a known Struts vulnerability"
              echo "that remained unpatched for 2 months after the fix was available."
              echo "Patch critical CVEs within 72 hours."
              EXIT_CODE=1
            fi
          fi
          exit $EXIT_CODE

      - name: Check for outdated critical dependencies
        run: |
          if [ -f requirements.txt ]; then
            pip install pip-outdated 2>/dev/null || true
            if command -v pip-outdated >/dev/null 2>&1; then
              pip-outdated requirements.txt || true
            fi
          fi
          # Check for Maven/Gradle (Java projects like Struts)
          for pom in $(find . -name 'pom.xml' 2>/dev/null); do
            if grep -q 'struts' "$pom"; then
              echo "::error file=$pom::Apache Struts dependency found. Verify version is patched."
            fi
          done
          echo "Dependency freshness check complete."
```

---

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

---

## What You Learned

- **The Equifax breach was entirely preventable.** The patch existed for two months. The scanner found it. The process failed.
- **Scanning without remediation workflow is security theater.** Scan, ticket, assign, SLA, verify, escalate. Equifax only did step 1.
- **The cost of not patching: $700M settlement + $1.4B remediation vs. ~40 hours of engineering time.**

## Further Reading

- [US House Committee: The Equifax Data Breach Report](https://oversight.house.gov/wp-content/uploads/2018/12/Equifax-Report.pdf)
- [Apache Struts: CVE-2017-5638 Advisory](https://cwiki.apache.org/confluence/display/WW/S2-045)
- [FTC: Equifax Data Breach Settlement](https://www.ftc.gov/enforcement/refunds/equifax-data-breach-settlement)
