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

Focus on the trust question behind the steps: once an artifact is published, how does anyone else know they are installing the same bytes you intended to publish?

1. Navigate to the demo library source code:
   ```bash
   cd /lab/src/packages/demo-lib
   ```

2. Inspect `setup.py` and `demo_lib.py`. The version is `1.0.0`.

3. Build the artifact:
   ```bash
   python setup.py sdist
   ```

4. Publish to the private PyPI registry:
   ```bash
   pip install twine
   twine upload --skip-existing --repository-url http://pypi-private:8080/ dist/*
   ```

   For this lab, the registry is intentionally permissive so you can see the integrity problem clearly. If prompted for credentials, any username and password will work. `--skip-existing` keeps this step repeatable if the good artifact is already present.

5. Verify the package is available:
   ```bash
   curl http://pypi-private:8080/simple/demo-lib/
   ```
