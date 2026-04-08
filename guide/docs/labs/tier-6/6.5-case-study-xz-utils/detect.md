# Lab 6.5: Case Study: xz-utils (CVE-2024-3094)

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

## Indicators of the xz-utils Backdoor

The backdoor was designed to be invisible at the application and network layer. Detection focused on **host-level indicators**: vulnerable liblzma version, SSH authentication latency, and unexpected sshd CPU usage.

**Key indicators:**

- liblzma version 5.6.0 or 5.6.1 installed
- SSH authentication taking >200ms longer than baseline
- `sshd` consuming unexpected CPU during authentication
- Release tarballs that do not match git source builds

| Indicator | What It Means |
|-----------|---------------|
| `dpkg -l liblzma5` showing 5.6.0 or 5.6.1 | Vulnerable version installed |
| `ldd /usr/sbin/sshd` showing liblzma linkage | sshd linked against potentially backdoored library |
| `sshd` CPU spike during key exchange | Backdoor executing during RSA verification |

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Backdoor injected into release tarballs via compromised maintainer |
| **Modify Authentication Process** | [T1556](https://attack.mitre.org/techniques/T1556/) | Backdoor hooked RSA signature verification in sshd |
| **Trusted Relationship** | [T1199](https://attack.mitre.org/techniques/T1199/) | Attacker gained access through social engineering of maintainer trust |

**Alert:** "Vulnerable liblzma version detected (CVE-2024-3094)"

**Triage steps:**

1. Query SBOM for liblzma 5.6.0/5.6.1
2. Check if sshd links against liblzma: `ldd /usr/sbin/sshd | grep lzma`
3. If linked on systemd-based distros, the system is exploitable
4. Downgrade to 5.4.x immediately
5. Check SSH access logs for the exposure window

---

## What You Learned

- **Social engineering is the most dangerous supply chain vector.** The attacker spent two years building trust, including sock puppet pressure campaigns.
- **Release tarballs can differ from git source.** The backdoor existed only in the tarball. Building from git tags prevents this class of attack.
- **Sole-maintainer projects are the highest-risk dependencies.** The entire attack was enabled by one overworked maintainer who could be socially engineered.

## Further Reading

- [Andres Freund's Original Disclosure (oss-security)](https://www.openwall.com/lists/oss-security/2024/03/29/4)
- [Evan Boehs: Everything I Know About the xz Backdoor](https://boehs.org/node/everything-i-know-about-the-xz-backdoor)
- [OpenSSF: Lessons from the xz-utils Compromise](https://openssf.org/blog/2024/03/30/xz-backdoor-cve-2024-3094/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
