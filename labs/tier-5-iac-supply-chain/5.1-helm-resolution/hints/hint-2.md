The fix is to pin exact chart versions and use only your private repo:

```bash
# Remove the untrusted public repo
helm repo remove untrusted-public

# Update Chart.yaml to use exact version pins (e.g., version: "2.3.1")
# Then rebuild the lock file
helm dependency update /app/webapp/

# Verify the Chart.lock contains digests
cat /app/webapp/Chart.lock
```

The `Chart.lock` file pins exact versions with SHA digests, similar to how
`package-lock.json` or `pip freeze` work. Always commit it to version control.
