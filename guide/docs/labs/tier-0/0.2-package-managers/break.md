# Lab 0.2: How Package Managers Work

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

## Malicious Code in setup.py

### Step 1: First, verify /tmp/pwned does not exist

```bash
ls -la /tmp/pwned 2>&1
```

You should see "No such file or directory".

### Step 2: Look at the malicious package (before installing)

```bash
cd /workspace/inspect
pip download --index-url http://pypi-private:8080/simple/ --trusted-host pypi-private \
    --no-deps -d . malicious-utils
tar xzf malicious-utils-*.tar.gz
cat malicious-utils-1.0.0/setup.py
```

The `setup.py` contains normal package setup code plus **a malicious payload** that writes to `/tmp/pwned`. In a real attack, this could steal API keys, install backdoors, or exfiltrate source code. The malicious code runs **during installation**, before the package is even usable.

### Step 3: Install the malicious package

```bash
pip install --index-url http://pypi-private:8080/simple/ --trusted-host pypi-private malicious-utils
```

In a real attack, there would be no warning. The malicious code would run silently.

### Step 4: Check the damage

```bash
cat /tmp/pwned
```

You should see:
```
You have been compromised!
This code ran as user: root
...
```

**The package's `setup.py` ran arbitrary code the moment you ran `pip install`.** You didn't import it. You didn't run it. Just installing it was enough.

**Checkpoint:** You should now have `/tmp/pwned` containing the compromise proof, and `malicious-utils` installed in your Python environment.

### Step 5: Think about scale

On the real PyPI (pypi.org), there are over 500,000 packages. Any one of them could have a malicious `setup.py`. Typosquatting attacks ([Lab 1.3](../../tier-1/1.3-typosquatting/)) create packages with names like `reqeusts` instead of `requests`, hoping people make typos.
