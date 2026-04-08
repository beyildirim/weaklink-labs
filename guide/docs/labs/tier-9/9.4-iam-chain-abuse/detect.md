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

### CI Integration

Add this workflow to audit IAM trust policies for excessive cross-account role chaining. Save as `.github/workflows/iam-chain-audit.yml`:

```yaml
name: IAM Trust Chain Audit

on:
  pull_request:
    paths:
      - "terraform/**"
      - "iam/**"
      - "cloudformation/**"
      - "*.tf"

permissions:
  contents: read

jobs:
  audit-iam-chains:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Detect cross-account AssumeRole chains
        run: |
          EXIT_CODE=0
          CHAIN_DEPTH=0

          for f in $(find . -name '*.tf' -o -name '*.json' 2>/dev/null | head -100); do
            # Count AssumeRole trust relationships per file
            ASSUME_ROLES=$(grep -c 'sts:AssumeRole\|AssumeRolePolicyDocument' "$f" 2>/dev/null || true)
            if [ "$ASSUME_ROLES" -gt 2 ]; then
              echo "::warning file=$f::$ASSUME_ROLES AssumeRole relationships found."
              echo "Excessive role chaining creates transitive trust paths."
              CHAIN_DEPTH=$((CHAIN_DEPTH + ASSUME_ROLES))
            fi

            # Check for wildcard principals in trust policies
            WILD_TRUST=$(grep -nE '"Principal".*"\*"|principal.*=.*"\*"' "$f" || true)
            if [ -n "$WILD_TRUST" ]; then
              echo "::error file=$f::Wildcard principal in trust policy:"
              echo "$WILD_TRUST"
              echo "Any AWS account can assume this role."
              EXIT_CODE=1
            fi

            # Check for missing external ID conditions
            CROSS_ACCOUNT=$(grep -l 'arn:aws:iam::[0-9]' "$f" 2>/dev/null || true)
            if [ -n "$CROSS_ACCOUNT" ]; then
              EXT_ID=$(grep -c 'sts:ExternalId\|externalId\|external_id' "$f" || true)
              if [ "$EXT_ID" -eq 0 ]; then
                echo "::warning file=$f::Cross-account trust without ExternalId condition."
                echo "Add sts:ExternalId to prevent confused deputy attacks."
              fi
            fi
          done

          if [ "$CHAIN_DEPTH" -gt 5 ]; then
            echo "::error::Total role chain depth across configs: $CHAIN_DEPTH"
            echo "Reduce transitive trust. Use OIDC federation instead of role chains."
            EXIT_CODE=1
          fi

          if [ "$EXIT_CODE" -eq 0 ]; then
            echo "PASS: No excessive IAM chain patterns detected."
          fi
          exit $EXIT_CODE
```

---

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

---

## What You Learned

- Cloud IAM is a supply chain. Trust relationships form transitive chains enabling traversal from low-privilege to high-privilege accounts.
- The attack is fast: 8 minutes from dev credential theft to production data exfiltration with no alerts in default configuration.
- OIDC federation eliminates the chain entirely. No long-lived credentials means no transitive chain to traverse.

## Further Reading

- [AWS: Cross-Account Access Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html)
- [AWS: How to Use External ID](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html)
- [Rhino Security Labs: AWS IAM Privilege Escalation](https://rhinosecuritylabs.com/aws/aws-privilege-escalation-methods-mitigation/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
