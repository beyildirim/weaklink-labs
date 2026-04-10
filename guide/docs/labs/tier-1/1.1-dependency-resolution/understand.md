# Lab 1.1: How Dependency Resolution Works

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

## How pip Resolves Dependencies

Focus on the decision points in the resolver. The important lesson is not that `pip` has flags. It is that small configuration choices determine which source wins when the same package name exists in multiple places.

### Step 1: Look at your application

```bash
cat /app/requirements.txt
```

The app depends on `internal-utils==1.0.0` and `data-processor==2.0.0`, hosted on the private registry.

### Step 2: Check pip configuration

```bash
cat /etc/pip.conf
```

- `index-url` points to the **private** registry
- `extra-index-url` points to the **public** registry

This is a common (and dangerous) pattern in corporate environments.

### Step 3: Install dependencies

```bash
pip install -r requirements.txt
```

Pip resolves all packages from the private registry.

### Step 4: Visualize the dependency tree

```bash
pipdeptree
```

`data-processor` depends on `internal-utils`, which depends on `logging-helper`. Pip figured out the entire chain.

### Step 5: Test the app

```bash
python app.py
```

### Step 6: Explore lockfiles

```bash
pip freeze
```

This shows every installed package at its exact version. Without a lockfile, the same `requirements.txt` can produce different results at different times.

### Step 7: Experiment with version pins

```bash
sed -i 's/internal-utils==1.0.0/internal-utils>=1.0.0/' requirements.txt
pip install --force-reinstall -r requirements.txt
```

When you use `>=` instead of `==`, pip looks for the **highest available version across ALL configured registries**.

```bash
pip show internal-utils
python app.py
```

If you got version 99.0.0, you just saw the problem with `--extra-index-url`.

**Reset before continuing:**

```bash
sed -i 's/internal-utils>=1.0.0/internal-utils==1.0.0/' requirements.txt
pip install --force-reinstall -r requirements.txt
```
