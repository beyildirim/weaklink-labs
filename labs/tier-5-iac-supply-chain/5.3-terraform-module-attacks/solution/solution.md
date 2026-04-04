# Solution: Lab 5.3

## Key actions

1. Find the malicious provisioner:

```bash
grep -r 'local-exec' /app/infra/modules/
cat /app/infra/modules/s3-bucket/main.tf
```

2. Remove the `null_resource` with the `local-exec` provisioner that exfiltrates credentials.

3. Pin the module to a local path in `main.tf`:

```hcl
module "storage" {
  source = "./modules/s3-bucket"
  # no version -- local module, code reviewed
}
```

4. Create the provider lock file:

```bash
cd /app/infra && terraform providers lock
```

## Why it works

- `local-exec` provisioners run arbitrary shell commands during `terraform apply`
- They execute with the same permissions as the Terraform process (which has cloud credentials)
- Pinning modules to local reviewed copies eliminates the risk of remote module tampering
- The `.terraform.lock.hcl` file pins provider versions with cryptographic hashes
- `null_resource` blocks with provisioners are a red flag during code review
