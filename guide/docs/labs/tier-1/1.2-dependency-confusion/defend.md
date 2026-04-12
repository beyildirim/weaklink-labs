# Lab 1.2: Dependency Confusion

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

## Eliminating the Confusion

The attack succeeded because `extra-index-url` told pip to search both registries. The fix is a one-word configuration change.

### Fix 1: Use --index-url (not --extra-index-url)

Clean up the compromise marker from Phase 2:

```bash
rm -f /tmp/dependency-confusion-pwned
```

Look at the current (vulnerable) pip config:

```bash
cat /etc/pip.conf
```

The problem: `extra-index-url` tells pip to search **both** the private registry and the public one. Pip picks whichever has the highest version, which is how the attacker won.

Now replace it with the safe config that uses `index-url` instead:

```bash
cp /etc/pip-configs/pip.conf.safe /etc/pip.conf
cat /etc/pip.conf
```

The difference: `index-url` (without `extra-`) makes pip search **only** the specified registry. The public registry is gone. Even if the attacker publishes `wl-auth==99.0.0` on public PyPI, pip will never see it.

### Fix 2: Restore and reinstall

```bash
echo "wl-auth==1.0.0" > requirements.txt
pip uninstall -y wl-auth
pip install -r requirements.txt
```

### Fix 3: Verify the defense

```bash
pip show wl-auth
python app.py
python3 /app/scripts/check_compromise.py
```

You should see version 1.0.0 installed and no compromise detected.

### Additional defenses

1. **`--require-hashes`**: Pin packages to SHA256 hashes. Even if an attacker publishes the same name+version, the hash won't match.
2. **Register internal names on public PyPI**: Claim the namespace with an empty `0.0.1` package.
3. **Repository manager** (Artifactory, Nexus): Proxy public PyPI and prefer private packages by name pattern.
