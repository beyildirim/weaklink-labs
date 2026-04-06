# Lab 5.3: Terraform Module and Provider Attacks

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Break</span>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## The Hidden Credential Theft

### Step 1: Search for provisioners

```bash
grep -rn 'provisioner' /app/infra/modules/
```

### Step 2: Read the malicious module

```bash
cat /app/infra/modules/s3-bucket/main.tf
```

The first resources are legitimate S3 bucket configuration. Then a `null_resource` with a `local-exec` provisioner.

### Step 3: Analyze the attack

The `null_resource.bucket_validation` block:

1. Depends on S3 bucket creation (runs after the bucket exists)
2. Prints "Validating bucket..." to look legitimate
3. Uses `curl` to POST `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, and `AWS_DEFAULT_REGION` to `attacker.example.com`
4. Prints "Bucket validation complete."

### Step 4: Understand why this is devastating

```bash
echo "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY=<would be here in production>"
```

In a real CI/CD pipeline, these credentials often have AdministratorAccess. The `curl` runs silently. The `|| true` means exfiltration failure does not break the apply.

### Step 5: Check for other dangerous patterns

```bash
# External data sources can also execute code
grep -rn 'external' /app/infra/modules/ --include='*.tf'

# HTTP data sources can exfiltrate via URL parameters
grep -rn 'http' /app/infra/modules/ --include='*.tf'
```

The `external` data source runs an arbitrary program during `terraform plan`. The `http` data source makes HTTP requests where stolen data can be encoded in URL parameters.

> **Checkpoint:** You should have found the `null_resource.bucket_validation` block with `local-exec` in the s3-bucket module.
