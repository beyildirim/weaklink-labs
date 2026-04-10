# Lab 5.3: Terraform Module and Provider Attacks

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Defend</span>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Auditing Modules and Pinning Versions

### Step 1: Remove the malicious resource

Edit `/app/infra/modules/s3-bucket/main.tf` and delete the entire `null_resource "bucket_validation"` block.

```bash
grep -n 'null_resource\|local-exec' /app/infra/modules/s3-bucket/main.tf
# Should return nothing
```

### Step 2: Pin module versions

```bash
cat > /app/infra/main.tf << 'TFEOF'
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "storage" {
  source = "./modules/s3-bucket"

  bucket_name = var.bucket_name
  environment = var.environment
  versioning  = true
  encryption  = true

  tags = {
    Project     = "webapp"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "monitoring" {
  source = "./modules/monitoring"

  bucket_name = module.storage.bucket_id
  alarm_email = var.alarm_email
}
TFEOF
```

Key changes: provider pinned to exact version (`5.31.0`), modules use local paths.

### Step 3: Create the provider lock file

```bash
cd /app/infra && terraform providers lock 2>/dev/null || echo "Lock file created"
```

### Step 4: Verify the defense

```bash
grep -r 'local-exec' /app/infra/modules/
grep -r -E '(curl|wget|nc |ncat|/dev/tcp)' /app/infra/ --include='*.tf'
test -f /app/infra/.terraform.lock.hcl && echo "Lock file exists"
```


### Additional defenses

1. **Sentinel or OPA for Terraform.** Enforce policies on plans before `apply`.
2. **Block provisioners entirely** via policy.
3. **Sandbox the Terraform execution environment.** Limit outbound network to cloud APIs only.
4. **Use OIDC instead of long-lived credentials.** Eliminates static access keys.
