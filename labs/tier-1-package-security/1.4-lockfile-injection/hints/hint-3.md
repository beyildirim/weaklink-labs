Complete solution:

```bash
# 1. Clean up compromise marker
rm -f /tmp/lockfile-pwned

# 2. Regenerate the lockfile from source
cd /app/project
pip-compile --generate-hashes \
    --index-url http://pypi:8080/simple/ \
    --trusted-host pypi \
    requirements.in \
    --output-file requirements.txt

# 3. Verify the lockfile integrity script works
bash verify-lockfile.sh requirements.in requirements.txt
```

Run `weaklink verify 1.4` from your host machine to check.
