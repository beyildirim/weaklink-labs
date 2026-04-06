# Lab 0.2: How Package Managers Work

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

## Hash Verification with --require-hashes

### Step 1: Clean up from the attack

```bash
pip uninstall -y malicious-utils safe-utils 2>/dev/null
rm -f /tmp/pwned
```

### Step 2: Get the hash of the safe package

```bash
SAFE_HASH=$(pip hash /workspace/inspect/safe-utils-1.0.0.tar.gz 2>/dev/null | grep sha256 | cut -d: -f2)
echo "Safe package hash: sha256:${SAFE_HASH}"
```

If the above fails (older pip):

```bash
SAFE_HASH=$(python -c "
import hashlib, glob
f = glob.glob('/workspace/inspect/safe-utils-*.tar.gz')[0]
print(hashlib.sha256(open(f,'rb').read()).hexdigest())
")
echo "Safe package hash: sha256:${SAFE_HASH}"
```

### Step 3: Create a requirements file with hashes

```bash
cat > /workspace/requirements.txt << EOF
safe-utils==1.0.0 --hash=sha256:${SAFE_HASH}
EOF

cat /workspace/requirements.txt
```

This tells pip: "Only install `safe-utils` version 1.0.0 if its hash matches exactly."

### Step 4: Install with hash verification

```bash
pip install --require-hashes \
    --index-url http://pypi-private:8080/simple/ --trusted-host pypi-private \
    -r /workspace/requirements.txt
```

### Step 5: Try to install the malicious package with wrong hash

```bash
cat > /workspace/requirements-evil.txt << EOF
malicious-utils==1.0.0 --hash=sha256:${SAFE_HASH}
EOF

pip install --require-hashes \
    --index-url http://pypi-private:8080/simple/ --trusted-host pypi-private \
    -r /workspace/requirements-evil.txt 2>&1 || true
```

pip **refuses** because the hash does not match.

### Step 6: Verify the defense worked

```bash
ls -la /tmp/pwned 2>&1
```

"No such file or directory". The malicious `setup.py` never ran.

### Step 7: Verify the lab

```bash
weaklink verify 0.2
```
