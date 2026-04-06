# Lab 2.4: Secret Exfiltration from CI

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

## Locking Down CI Secrets

### Fix 1: Apply the hardened CI config

```bash
cd /repos/wl-webapp
cp /lab/src/repo/.gitea/workflows/ci-hardened.yml .gitea/workflows/ci.yml
cp /lab/src/repo/.gitea/workflows/pr-ci.yml .gitea/workflows/pr-ci.yml
cat .gitea/workflows/ci.yml
```

Key changes:

1. **No global secrets**. removed the top-level `env:` block
2. **Secrets scoped to deploy only**
3. **No secrets in artifacts**
4. **PR builds have zero secrets**. separate `pr-ci.yml`

### Fix 2: Clean up compromised artifacts

```bash
rm -f dist/build.log
rm -rf dist/
```

### Fix 3: Commit the defense

```bash
git add -A
git commit -m "Remove secrets from build artifacts and scope to deploy only"
git push origin main
```

### Additional defenses

1. **Network egress controls**: restrict CI runners to known registries and deployment targets
2. **DNS monitoring on runners**: watch for long/encoded subdomains from CI infrastructure
3. **Artifact scanning**: scan uploaded artifacts for secret patterns before making them available
4. **Short-lived OIDC credentials** instead of long-lived secrets

### Step 4: Final verification

```bash
weaklink verify 2.4
```
