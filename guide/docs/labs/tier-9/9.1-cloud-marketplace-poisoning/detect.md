# Lab 9.1: Cloud Marketplace Poisoning

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

**Goal:** Detect compromised marketplace images using cloud audit logs and host-based detection.

Cloud audit indicators:

| Indicator | Log Source |
|-----------|-----------|
| AMI launch from unknown publisher | CloudTrail `RunInstances` |
| Instance metadata API called at boot | VPC Flow Logs |
| Outbound DNS to unknown domains | Route 53 Resolver / VPC DNS |
| Outbound HTTP to `cloud-analytics.io` | VPC Flow Logs / proxy |
| SSH login from unexpected IP | CloudTrail / auth.log |

## MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| Supply Chain Compromise: Software Supply Chain | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Malicious image via cloud marketplace |
| Implant Internal Image | [T1525](https://attack.mitre.org/techniques/T1525/) | Backdoor pre-installed before deployment |
| Valid Accounts: Cloud Accounts | [T1078.004](https://attack.mitre.org/techniques/T1078/004/) | Pre-installed SSH key provides persistent access |

## What You Learned

- Cloud marketplace images contain everything the publisher put in, including potential backdoors in cron jobs, SSH keys, and system services.
- Marketplace verification is shallow. It checks boot and metadata, not contents.
- Build from scratch using minimal base images and IaC. That is the only safe approach.

## Further Reading

- [MITRE ATT&CK: Implant Internal Image (T1525)](https://attack.mitre.org/techniques/T1525/)
- [AWS: AMI Best Practices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html)
- [Chainguard Images: Minimal Base Images](https://www.chainguard.dev/chainguard-images)
