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

1. Start from the workspace scaffold for this lab:
   ```bash
   cd /workspace/artifact-demo
   ```

2. Get the hash of the known-good artifact that was prepared before you tampered with the registry:
   ```bash
   GOOD_HASH=$(sha256sum reference/demo_lib-1.0.0.tar.gz | awk '{print $1}')
   echo "Known-good hash: sha256:${GOOD_HASH}"
   ```

   This file is your trusted reference copy. Do not hash the current registry download here, because the whole point of the lab is that the registry copy may already be tampered.

3. Paste the known-good hash into `requirements.txt`, replacing the version-only pin:
   ```bash
   cat > requirements.txt << EOF
   demo-lib==1.0.0 --hash=sha256:${GOOD_HASH}
   EOF

   cat requirements.txt
   ```

4. Try to install from the registry with hash verification enabled:
   ```bash
   pip install --no-cache-dir --force-reinstall \
       --index-url http://pypi-private:8080/simple/ --trusted-host pypi-private \
       -r requirements.txt --require-hashes 2>&1 | tee hash-check.log || true
   ```
   Because the registry now serves the tampered artifact from the Break phase, pip should refuse to install it with a hash mismatch.

5. Confirm the defense blocked the tampered artifact:
   ```bash
   grep -i "do not match the hashes" hash-check.log
   ```

   The important lesson is not "hash a package from the registry." It is "pin the exact bytes you trusted earlier and refuse anything else."
