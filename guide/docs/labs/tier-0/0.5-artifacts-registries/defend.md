# Lab 0.5: Artifacts & Registries

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

## Using Cryptographic Hashes

An artifact's contents can change even if the version number stays the same. Cryptographic checksums verify integrity.

1. Get the hash of the *good* artifact by running the integrity script:
   ```bash
   /labs/tier-0-foundations/0.5-artifacts-registries/src/scripts/verify-integrity.sh
   ```

   The script downloads the package from the registry and prints its SHA256 hash. Copy the full `--hash=sha256:...` line from the output.

2. Paste the hash into `requirements.txt`, replacing the version-only pin:
   ```bash
   cd /workspace/artifact-demo
   ```
   Edit `requirements.txt` so it reads:
   ```text
   demo-lib==1.0.0 --hash=sha256:<paste the hash from step 1>
   ```
   Use the exact hash the script printed. Do not copy a hash from this guide page.

3. Install with hash verification enabled:
   ```bash
   pip install -r requirements.txt --require-hashes
   ```
   This succeeds because the downloaded package matches the pinned hash. If someone replaces the package on the registry (as you did in the Break phase), the hash will not match and pip will refuse to install it.

### Verify the lab

```bash
weaklink verify 0.5
```
