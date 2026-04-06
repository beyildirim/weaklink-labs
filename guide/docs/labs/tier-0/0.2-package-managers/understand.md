# Lab 0.2: How Package Managers Work

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

## How pip install Works

### Step 1: Browse the local package server

List all packages on the registry. The grep extracts package names from the HTML index page:

```bash
curl -s http://pypi-private:8080/simple/ | grep -o 'href="[^"]*"'
```

You should see links for `safe-utils` and `malicious-utils`.

### Step 2: Install a safe package

```bash
pip install --index-url http://pypi-private:8080/simple/ --trusted-host pypi-private safe-utils
```

pip downloaded `safe-utils` as a `.tar.gz`, extracted it, and ran `setup.py install`.

### Step 3: Use the package

```bash
python -c "from safe_utils import greet; print(greet('Security Analyst'))"
```

### Step 4: Download and inspect without installing

```bash
mkdir -p /workspace/inspect
pip download --index-url http://pypi-private:8080/simple/ --trusted-host pypi-private \
    --no-deps -d /workspace/inspect safe-utils
cd /workspace/inspect
tar xzf safe-utils-*.tar.gz
cat safe-utils-1.0.0/setup.py
```

This is the file pip executes when installing. For `safe-utils`, it just defines metadata. **But setup.py is a full Python script. It can do anything.**
