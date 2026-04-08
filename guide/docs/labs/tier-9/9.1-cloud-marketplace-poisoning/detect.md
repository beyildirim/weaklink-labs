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

<div class="no-terminal-notice">Reference material. No terminal needed.</div>

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

### CI Integration

Add this workflow to verify cloud images are built from approved base images and not pulled from unvetted marketplace sources. Save as `.github/workflows/cloud-image-check.yml`:

```yaml
name: Cloud Image Source Verification

on:
  pull_request:
    paths:
      - "terraform/**"
      - "cloudformation/**"
      - "pulumi/**"
      - "packer/**"

permissions:
  contents: read

jobs:
  verify-image-sources:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check for unapproved AMI sources
        run: |
          EXIT_CODE=0
          APPROVED_OWNERS="amazon self 099720109477 137112412989"  # AWS, Canonical, Amazon Linux

          for f in $(find . -name '*.tf' -o -name '*.json' 2>/dev/null | \
            grep -E 'terraform|cloudformation|packer'); do
            # Check for hardcoded AMI IDs without owner verification
            AMIS=$(grep -nE 'ami-[0-9a-f]{8,17}' "$f" || true)
            if [ -n "$AMIS" ]; then
              echo "::warning file=$f::Hardcoded AMI IDs found:"
              echo "$AMIS"
              echo "Verify these AMIs belong to approved publishers."
            fi

            # Check for marketplace image references without owner filters
            MARKETPLACE=$(grep -n 'most_recent.*true' "$f" || true)
            if [ -n "$MARKETPLACE" ]; then
              OWNER_CHECK=$(grep -c 'owners' "$f" || true)
              if [ "$OWNER_CHECK" -eq 0 ]; then
                echo "::error file=$f::AMI data source uses most_recent without owner filter."
                echo "Always specify 'owners' to prevent marketplace poisoning."
                EXIT_CODE=1
              fi
            fi
          done
          if [ "$EXIT_CODE" -eq 0 ]; then
            echo "PASS: All image sources use owner verification."
          fi
          exit $EXIT_CODE

      - name: Verify Packer builds use approved base images
        run: |
          for f in $(find packer/ -name '*.pkr.hcl' -o -name '*.json' 2>/dev/null); do
            if grep -q 'source_ami' "$f" && ! grep -q 'owners' "$f"; then
              echo "::warning file=$f::Packer template references AMI without owner filter."
            fi
          done
          echo "Packer base image check complete."
```

---

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

---

## What You Learned

- Cloud marketplace images contain everything the publisher put in, including potential backdoors in cron jobs, SSH keys, and system services.
- Marketplace verification is shallow. It checks boot and metadata, not contents.
- Build from scratch using minimal base images and IaC. That is the only safe approach.

## Further Reading

- [MITRE ATT&CK: Implant Internal Image (T1525)](https://attack.mitre.org/techniques/T1525/)
- [AWS: AMI Best Practices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html)
- [Chainguard Images: Minimal Base Images](https://www.chainguard.dev/chainguard-images)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
