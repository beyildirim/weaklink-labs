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

1. Get the hash of the *good* artifact:
   ```bash
   /labs/tier-0-foundations/0.5-artifacts-registries/src/scripts/verify-integrity.sh
   ```

2. Enforce this hash in `requirements.txt`:
   ```text
   demo-lib==1.0.0 --hash=sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
   ```

3. Running `pip install -r requirements.txt` with `--require-hashes` will reject the tampered file, preventing the attack.

### Verify the lab

```bash
weaklink verify 0.5
```
