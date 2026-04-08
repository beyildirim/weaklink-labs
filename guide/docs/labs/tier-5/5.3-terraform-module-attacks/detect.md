# Lab 5.3: Terraform Module and Provider Attacks

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

## Finding Terraform-Based Credential Theft

The core signal is outbound network connections from Terraform to unexpected destinations. `local-exec` provisioners run as child processes of `terraform`, so process trees and network telemetry from CI runners are the primary detection surface.

**Key indicators:**

- `curl`, `wget`, or `nc` as child processes of `terraform` during `apply`
- Outbound HTTP POST from CI runners to non-cloud-API endpoints during Terraform runs
- `null_resource` blocks in plan output
- Environment variable access from Terraform child processes

| Indicator | What It Means |
|-----------|---------------|
| HTTP POST to non-AWS/GCP/Azure IP from CI runner during TF apply | Credential exfiltration |
| DNS query for unknown domain from Terraform environment | local-exec phoning home |
| `curl`/`wget` process spawned by `terraform` | local-exec running network commands |

### CI Integration

Block local-exec and external data sources in every PR:

```yaml
name: Terraform Module Security Check

on:
  pull_request:
    paths:
      - "**/*.tf"
      - "**/.terraform.lock.hcl"

jobs:
  scan-terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Block local-exec provisioners
        run: |
          FOUND=0
          for f in $(find . -name "*.tf" -not -path "*/.terraform/*"); do
            if grep -q 'local-exec' "$f"; then
              echo "::error file=$f::BLOCKED: Contains local-exec provisioner."
              FOUND=1
            fi
          done
          [ "$FOUND" -eq 0 ] || exit 1

      - name: Verify lock file exists
        run: |
          for tf_dir in $(find . -name "*.tf" -exec dirname {} \; | sort -u); do
            if ls "$tf_dir"/*.tf 1>/dev/null 2>&1; then
              if [ ! -f "$tf_dir/.terraform.lock.hcl" ]; then
                echo "::error::$tf_dir has .tf files but no .terraform.lock.hcl"
                exit 1
              fi
            fi
          done
```

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Compromise Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Malicious code in Terraform module from public registry |
| **Command and Scripting Interpreter** | [T1059](https://attack.mitre.org/techniques/T1059/) | `local-exec` runs arbitrary shell commands during `terraform apply` |

**Alerts:** "Terraform process spawned curl/wget on CI runner" (EDR), "Outbound POST from CI subnet to non-cloud endpoint" (proxy/firewall).

**Triage workflow:**

1. **Check process tree.** Did `terraform` spawn `curl`, `wget`, or any network tool?
2. **Identify the module.** Local (code-reviewed) or registry (third-party)?
3. **Check destination.** If not a cloud API endpoint, treat as exfiltration.
4. **Rotate credentials immediately** if exfiltration is confirmed.
5. **Audit module source.** Check commit history for recently added provisioners.

---

## What You Learned

- **`local-exec` is arbitrary code execution** on the machine running Terraform, with full access to environment variables. `null_resource` exists only to run provisioners; treat it as a red flag.
- **Pin everything.** Exact provider versions, `.terraform.lock.hcl` for hashes, local or pinned module sources.
- **`terraform plan` is not safe either.** `external` and `http` data sources execute during `plan`, not just `apply`.

## Further Reading

- [Terraform Documentation: Provisioners](https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax)
- [Terraform Documentation: Provider Lock File](https://developer.hashicorp.com/terraform/language/files/dependency-lock)
- [Alex Kaskasoli: Attacking Terraform Environments (2023)](https://blog.kaskasoli.com/2023/08/attacking-terraform-environments.html)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
