# Lab 2.4: Secret Exfiltration from CI

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

## How Secrets Live in CI

### Step 1: Examine the CI config

```bash
cd /repos/wl-webapp
cat .gitea/workflows/ci.yml
```

Three secrets injected globally: `DEPLOY_TOKEN`, `DB_PASSWORD`, `API_KEY`. Every job and step can read them.

### Step 2: Check the build step

The `build` job writes secrets to a file:

```yaml
- name: Build
  run: |
    echo "Build config: DB=$DB_PASSWORD API=$API_KEY" > dist/build.log
```

This gets uploaded as a build artifact. Anyone who downloads it gets the secrets.

### Step 3: Understand the artifact upload

```yaml
- name: Upload artifact
  uses: actions/upload-artifact@v4
  with:
    path: |
      webapp.tar.gz
      dist/build.log  # <-- contains secrets!
```
