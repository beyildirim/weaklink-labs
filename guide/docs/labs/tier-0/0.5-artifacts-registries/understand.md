# Lab 0.5: Artifacts & Registries

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step upcoming">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Publishing and Downloading

1. Navigate to the demo library source code:
   ```bash
   cd /labs/tier-0-foundations/0.5-artifacts-registries/src/packages/demo-lib
   ```

2. Inspect `setup.py` and `demo_lib.py`. The version is `1.0.0`.

3. Build the artifact:
   ```bash
   python setup.py sdist
   ```

4. Publish to the private PyPI registry:
   ```bash
   pip install twine
   twine upload --repository-url http://pypi-private:8080/ dist/*
   # Enter blank or any credentials, the lab registry accepts anything.
   ```

5. Verify the package is available:
   ```bash
   curl http://pypi-private:8080/simple/demo-lib/
   ```
