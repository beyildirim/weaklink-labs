# Lab 2.3: Indirect Poisoned Pipeline Execution

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

## Verifying CI-Referenced File Integrity

### Fix 1: Generate checksums for CI-referenced files

```bash
cd /repos/wl-webapp
git checkout main

# Restore clean Makefile and test script
cp /lab/src/repo/Makefile .
cp /lab/src/repo/scripts/run-tests.sh scripts/

# Generate checksums
sha256sum Makefile scripts/run-tests.sh > .ci-checksums
cat .ci-checksums
```

### Fix 2: Apply the hardened CI config

```bash
cp /lab/src/repo/.gitea/workflows/ci-hardened.yml .gitea/workflows/ci.yml
cat .gitea/workflows/ci.yml
```

The hardened config:

1. **Verifies checksums before execution**. a `verify-integrity` job checks that `Makefile` and `scripts/run-tests.sh` match known-good hashes
2. **Fails the pipeline if files are modified**
3. **Does not run on PRs**. PR validation uses a separate secret-free workflow
4. **Secrets scoped to deploy**

### Fix 3: Commit the defense

```bash
git add -A
git commit -m "Pin CI-referenced files by hash to prevent Indirect PPE"
git push origin main
```

### Additional defenses

1. **CODEOWNERS for ALL CI-referenced files**: Makefiles, scripts, Dockerfiles, test configs
2. **Separate PR and push builds**: PR builds never have secrets, so Indirect PPE yields nothing
3. **Inline CI logic**: move critical steps into the CI config itself instead of referencing external files

### Step 4: Final verification

```bash
weaklink verify 2.3
```
