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

### CI Integration

Add this workflow to audit Lambda layer versions and detect unauthorized layer modifications. Save as `.github/workflows/serverless-layer-check.yml`:

```yaml
name: Serverless Layer Audit

on:
  pull_request:
    paths:
      - "template.yaml"
      - "template.yml"
      - "serverless.yml"
      - "sam/**"
      - "layers/**"

permissions:
  contents: read

jobs:
  audit-serverless-layers:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check for unpinned Lambda layer versions
        run: |
          EXIT_CODE=0
          for f in $(find . -name 'template.y*ml' -o -name 'serverless.yml' 2>/dev/null); do
            # Check for layer ARNs without version pinning
            UNPINNED=$(grep -nE 'arn:aws:lambda:.*:layer:' "$f" | \
              grep -v ':[0-9]\+$' || true)
            if [ -n "$UNPINNED" ]; then
              echo "::error file=$f::Unpinned Lambda layer versions found:"
              echo "$UNPINNED"
              echo ""
              echo "Always pin layer versions (e.g., :42) to prevent silent replacement."
              EXIT_CODE=1
            fi
          done
          if [ "$EXIT_CODE" -eq 0 ]; then
            echo "PASS: All Lambda layers are version-pinned."
          fi
          exit $EXIT_CODE

      - name: Check for sitecustomize.py in layers
        run: |
          # sitecustomize.py auto-executes on Python Lambda cold start
          FOUND=$(find layers/ -name 'sitecustomize.py' 2>/dev/null || true)
          if [ -n "$FOUND" ]; then
            echo "::warning::sitecustomize.py found in layer source:"
            echo "$FOUND"
            echo ""
            echo "This file auto-executes during Python initialization."
            echo "Verify its contents are intentional and not malicious."
          else
            echo "PASS: No sitecustomize.py in layer sources."
          fi

      - name: Verify SAM build uses private registry
        run: |
          for f in $(find . -name 'template.y*ml' -o -name 'samconfig.toml' 2>/dev/null); do
            if grep -q 'pip install' "$f" && grep -q 'pypi.org' "$f"; then
              echo "::warning file=$f::SAM build references public PyPI directly."
              echo "Use a private registry to prevent dependency confusion."
            fi
          done
          echo "Registry source check complete."
```

---

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

---

## What You Learned

- Lambda Layers are a pre-execution attack surface. `sitecustomize.py` auto-loads without opt-in.
- Dependency confusion works in serverless pipelines. `sam build` defaults to public registries.
- VPC isolation prevents exfiltration. Without internet access, stolen data cannot leave your network.

## Further Reading

- [AWS: Lambda Layers](https://docs.aws.amazon.com/lambda/latest/dg/chapter-layers.html)
- [AWS: Lambda Security Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/lambda-security.html)
- [Python: sitecustomize documentation](https://docs.python.org/3/library/site.html)
