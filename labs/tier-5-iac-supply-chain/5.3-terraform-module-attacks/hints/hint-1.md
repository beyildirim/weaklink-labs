Check the module source code, not just the top-level `main.tf`. Terraform
modules can contain `provisioner` blocks that execute arbitrary commands:

```bash
# Look at all .tf files in the module
find /app/infra/modules/ -name '*.tf' -exec cat {} \;

# Search specifically for provisioners
grep -r 'provisioner' /app/infra/modules/
grep -r 'local-exec' /app/infra/modules/
```

Pay attention to `null_resource` blocks. They exist only to run provisioners
and have no actual infrastructure purpose.
