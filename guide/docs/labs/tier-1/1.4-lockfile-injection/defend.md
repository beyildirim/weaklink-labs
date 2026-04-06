# Lab 1.4: Lockfile Injection

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

## Lockfile Regeneration and CI Checks

### Defense 1: Clean up any compromise

```bash
rm -f /tmp/lockfile-pwned
```

### Defense 2: Regenerate the lockfile from source

The key defense: **never trust a lockfile diff in a PR. Always regenerate from source.**

```bash
cd /app/project
pip-compile --generate-hashes \
    --index-url http://pypi-private:8080/simple/ \
    --trusted-host pypi-private \
    requirements.in \
    --output-file requirements.txt
```

Compare to the PR's version:

```bash
diff <(grep -v "^#" requirements.txt) <(grep -v "^#" requirements.txt.malicious 2>/dev/null) && \
    echo "Files match (no tampering)" || echo "FILES DIFFER -- tampering detected!"
```

### Defense 3: Set up a CI check

```bash
cat /app/project/verify-lockfile.sh
```

Test against the legitimate lockfile:

```bash
cd /app/project
bash verify-lockfile.sh requirements.in requirements.txt
```

Test against a tampered lockfile:

```bash
cp requirements.txt requirements.txt.backup
sed -i 's/--hash=sha256:\([a-f0-9]\)/--hash=sha256:0/' requirements.txt
bash verify-lockfile.sh requirements.in requirements.txt
```

Restore:

```bash
cp requirements.txt.backup requirements.txt
```

### Verify your defenses

```bash
weaklink verify 1.4
```
