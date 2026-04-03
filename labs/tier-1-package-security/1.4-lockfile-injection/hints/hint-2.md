To regenerate the lockfile and detect tampering:

```bash
cd /app/project
pip-compile --generate-hashes \
    --index-url http://pypi:8080/simple/ \
    --trusted-host pypi \
    requirements.in \
    --output-file requirements.txt
```

This overwrites the tampered lockfile with a legitimate one.
Make sure `/tmp/lockfile-pwned` is removed too.
