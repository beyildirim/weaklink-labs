# Lab 5.3: Terraform Module and Provider Attacks

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step upcoming">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## How Terraform Modules and Providers Work

### Step 1: Examine the infrastructure project

```bash
cat /app/infra/main.tf
cat /app/infra/variables.tf
```

This project creates an S3 bucket using a "community module" and CloudWatch monitoring using a local module.

### Step 2: Understand module sources

| Source Type | Example | Risk Level |
|-------------|---------|------------|
| Terraform Registry | `hashicorp/consul/aws` | Medium: anyone can publish |
| GitHub | `github.com/user/repo` | Medium: repo can be compromised |
| Local path | `./modules/my-module` | Low: code is in your repo |
| S3/GCS | `s3::https://bucket/module.zip` | Low: controlled by you |

### Step 3: Check what the modules contain

```bash
ls -la /app/infra/modules/s3-bucket/
ls -la /app/infra/modules/monitoring/
```

### Step 4: Understand provisioners

Terraform has three provisioner types that run arbitrary commands:

- **`local-exec`**: runs on the machine running `terraform apply`
- **`remote-exec`**: runs on the remote resource via SSH/WinRM
- **`file`**: copies files to the remote resource

All three have full access to the Terraform process environment variables, including cloud credentials and CI tokens.

### Step 5: Understand providers

```bash
cat /app/infra/main.tf | grep -A5 'required_providers'
```

Providers are Go binaries Terraform downloads and executes. Anyone can publish a provider to the registry. A malicious provider steals credentials during `terraform plan` (not just `apply`).

### Step 6: Check the provider lock

```bash
cat /app/infra/.terraform.lock.hcl 2>/dev/null || echo "No lock file exists"
```

`.terraform.lock.hcl` pins provider versions with cryptographic hashes. Without it, `terraform init` downloads whatever version matches the constraint.
