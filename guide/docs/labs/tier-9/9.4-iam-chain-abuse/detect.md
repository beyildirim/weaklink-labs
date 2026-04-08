# Lab 9.4: IAM Chain Abuse

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step done">Defend</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Detect</span>
</div>

<div class="no-terminal-notice">Reference material. No terminal needed.</div>

**Goal:** Detect chain abuse via timing, source IP, and action pattern anomalies.

**Key insight:** Legitimate traversals follow a predictable pattern. Malicious traversals deviate in timing (seconds vs. minutes between hops), source IP, session duration, and subsequent actions.

Alert on: rapid cross-account AssumeRole chains (<2 min between hops), unexpected source IPs, maximum session duration requests, data access actions from deployment roles.

## MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| Valid Accounts: Cloud Accounts | [T1078.004](https://attack.mitre.org/techniques/T1078/004/) | Stolen cloud credentials initiate chain |
| Use Alternate Authentication Material | [T1550.001](https://attack.mitre.org/techniques/T1550/001/) | STS tokens chained via AssumeRole |
| Supply Chain Compromise: Software Supply Chain | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Initial access via malicious npm package |

## What You Learned

- Cloud IAM is a supply chain. Trust relationships form transitive chains enabling traversal from low-privilege to high-privilege accounts.
- The attack is fast: 8 minutes from dev credential theft to production data exfiltration with no alerts in default configuration.
- OIDC federation eliminates the chain entirely. No long-lived credentials means no transitive chain to traverse.

## Further Reading

- [AWS: Cross-Account Access Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html)
- [AWS: How to Use External ID](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html)
- [Rhino Security Labs: AWS IAM Privilege Escalation](https://rhinosecuritylabs.com/aws/aws-privilege-escalation-methods-mitigation/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
