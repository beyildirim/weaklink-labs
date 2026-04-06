# Solution: Lab 1.2

## Key actions

1. Remove the compromise marker:

```bash
rm -f /tmp/dependency-confusion-pwned
```

2. Fix pip configuration:

```bash
cp /etc/pip-configs/pip.conf.safe /etc/pip.conf
```

3. Uninstall the malicious package and reinstall the correct one:

```bash
pip uninstall -y wl-auth
pip install wl-auth==1.0.0
```

4. Verify:

```bash
pip show wl-auth          # Version: 1.0.0
python app.py               # No compromise detected
test ! -f /tmp/dependency-confusion-pwned && echo "CLEAN"
```

## Why the attack works

1. The pip config uses `--extra-index-url`, which makes pip search both registries
2. Pip picks the highest version across all sources (99.0.0 > 1.0.0)
3. The malicious package's setup.py runs arbitrary code during `pip install`
4. Code execution happens BEFORE the package is imported. Just installing it is enough

## Why the defense works

- `--index-url` (without `extra-`) tells pip to only check the private registry
- The public registry is never consulted, so the attacker's package is invisible
- Exact version pins (`==1.0.0`) prevent accidental upgrades even if the config is wrong
