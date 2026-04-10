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

This lab uses an intentionally permissive registry so you can see the trust failure clearly. An attacker with upload access can replace `demo-lib` version `1.0.0` with different contents while keeping the same version number.

1. Open the package source:

   ```bash
   cd /lab/src/packages/demo-lib
   ```

2. Edit `demo_lib.py`, adding a backdoor:
   ```python
   import os
   print(f"TAMPERED: running as {os.getenv('USER', 'unknown')}")
   ```

   Keep the version at `1.0.0`.

3. Rebuild the artifact:
   ```bash
   rm -rf dist
   python setup.py sdist
   ```

4. Re-upload to the registry:
   ```bash
   twine upload --repository-url http://pypi-private:8080/ dist/*
   ```

5. Anyone performing a clean `pip install demo-lib==1.0.0` now gets your malicious code despite the version number being identical.

**Checkpoint:** You should now have a tampered `demo-lib` 1.0.0 in the registry that prints the `TAMPERED` message on import, while the version number is unchanged.
