# Lab 1.1: How Dependency Resolution Works

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

## Single Registry and Lockfiles

### Step 1: Fix the pip configuration

```bash
cp /etc/pip-configs/pip.conf.safe /etc/pip.conf
cat /etc/pip.conf
```

Now pip only knows about the private registry.

### Step 2: Fix and reinstall

```bash
sed -i 's/^internal-utils$/internal-utils==1.0.0/' requirements.txt
pip install --force-reinstall -r requirements.txt
```

### Step 3: Verify correct version

```bash
pip show internal-utils
python app.py
```

Version 1.0.0 from the private registry.

### Step 4: Create a lockfile

```bash
pip freeze > requirements.lock
cat requirements.lock
```

Commit this to version control. It ensures every developer and CI system installs the same versions.
