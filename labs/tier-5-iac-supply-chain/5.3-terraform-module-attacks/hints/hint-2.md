The malicious `local-exec` provisioner is in the S3 bucket module. It uses
`curl` to exfiltrate environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
to an external server.

To fix:

```bash
# Remove the malicious null_resource from the module
# Edit /app/infra/modules/s3-bucket/main.tf and delete the null_resource block

# Pin the module version in main.tf using a local path:
# module "storage" {
#   source = "./modules/s3-bucket"
# }

# Create a lock file
cd /app/infra && terraform providers lock
```

Also check for `external` data sources. They can execute arbitrary programs too.
