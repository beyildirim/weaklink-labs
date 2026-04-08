# Lab 6.7: Case Study: Codecov Bash Uploader

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

## Identifying Script Modification and Secret Exfiltration

Core signal: **outbound HTTP POST from CI runners to unexpected endpoints** and **downloaded scripts with different hashes than expected**.

**Key indicators:**

- CI runners making HTTP POST to unapproved endpoints
- `curl | bash` or `wget | bash` in CI logs
- Downloaded scripts with SHA256 mismatches
- Large HTTP POST bodies from CI runners (env var dump)
- CI secrets accessed by steps that do not need them

| Indicator | What It Means |
|-----------|---------------|
| Outbound POST from CI runner to unknown IP | Env var exfiltration in progress |
| Downloaded script hash mismatch | Script modified at source or in transit |
| CI step accessing secrets it should not need | Overly broad secret exposure |

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Attacker modified the Codecov Bash Uploader on codecov.io |
| **Command and Scripting Interpreter: Bash** | [T1059.004](https://attack.mitre.org/techniques/T1059/004/) | Compromised script executed with full environment access |
| **Unsecured Credentials: Credentials In Files** | [T1552.001](https://attack.mitre.org/techniques/T1552/001/) | CI environment variables exfiltrated via HTTP POST |
| **Exfiltration Over Web Service** | [T1567](https://attack.mitre.org/techniques/T1567/) | Secrets sent to attacker-controlled server |

**Alert:** "CI runner making outbound POST to unapproved endpoint" or "Downloaded CI script hash mismatch."

The pattern trades security for convenience. When the script was modified, every CI pipeline became an exfiltration channel immediately. No PR needed, no code review, no deployment.

**Triage steps:**

1. Search all workflow files for `curl | bash` patterns
2. Assume all CI env vars from the exposure window are compromised
3. Rotate ALL secrets (AWS keys, tokens, passwords)
4. Check CI logs for outbound POST to unfamiliar endpoints
5. Audit downstream systems for stolen credential usage

---

## What You Learned

- **`curl | bash` is a supply chain attack waiting to happen.** No verification, no pinning, no visibility into changes.
- **CI environments are treasure troves of secrets.** A single exfiltration line captures every credential in environment variables.
- **Pin scripts by hash, not URL.** Verifying SHA256 before execution detects modifications at the source.

## Further Reading

- [Codecov: Bash Uploader Security Update](https://about.codecov.io/security-update/)
- [HashiCorp: Codecov Incident Response](https://discuss.hashicorp.com/t/hcsec-2021-12-codecov-security-event-and-hashicorp-gpg-key-exposure/23512)
- [OpenSSF: Best Practices for CI/CD Security](https://best.openssf.org/SCM-Best-Practices/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
