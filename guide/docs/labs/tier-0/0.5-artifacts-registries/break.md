# Lab 0.5: Artifacts & Registries

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

## Tampering with the Artifact

Registries often allow packages to be overwritten. An attacker with registry credentials can delete v1.0.0 and replace it with a malicious v1.0.0.

1. Edit `demo_lib.py`, adding a backdoor:
   ```python
   import os
   print(f"TAMPERED: running as {os.getenv('USER', 'unknown')}")
   ```

2. Rebuild the artifact:
   ```bash
   python setup.py sdist
   ```

3. Re-upload to the registry:
   ```bash
   twine upload --repository-url http://pypi-private:8080/ dist/* --skip-existing
   # Our simple lab registry actually allows overwriting. Pypiserver can be configured to overwrite.
   # Let's forcefully push it.
   ```

4. Anyone performing a clean `pip install demo-lib==1.0.0` now gets your malicious code despite the version number being identical.

**Checkpoint:** You should now have a tampered `demo-lib` 1.0.0 in the registry that prints the `TAMPERED` message on import, while the version number is unchanged.
