# Lab 9.2: Serverless Supply Chain

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

**Goal:** Detect compromised functions using CloudWatch and layer version auditing.

Compromised function behavioral changes:

| Metric | Baseline | Compromised |
|--------|----------|-------------|
| Duration P99 | 200ms | 350ms (+75% from exfil HTTP call) |
| Network bytes out | 2 KB/invocation | 5 KB/invocation |
| Cold start time | 800ms | 1200ms (sitecustomize.py overhead) |

## MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| Supply Chain Compromise: Software Supply Chain | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Malicious Lambda Layer |
| Acquire Infrastructure: Serverless | [T1583.007](https://attack.mitre.org/techniques/T1583/007/) | Serverless C2/exfil |
| Command and Scripting Interpreter | [T1059](https://attack.mitre.org/techniques/T1059/) | Malicious sitecustomize.py |

## What You Learned

- Lambda Layers are a pre-execution attack surface. `sitecustomize.py` auto-loads without opt-in.
- Dependency confusion works in serverless pipelines. `sam build` defaults to public registries.
- VPC isolation prevents exfiltration. Without internet access, stolen data cannot leave your network.

## Further Reading

- [AWS: Lambda Layers](https://docs.aws.amazon.com/lambda/latest/dg/chapter-layers.html)
- [AWS: Lambda Security Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/lambda-security.html)
- [Python: sitecustomize documentation](https://docs.python.org/3/library/site.html)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
