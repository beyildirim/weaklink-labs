# Solution: Lab 1.1

## Key actions

1. Replace the pip config to use `--index-url` only:

```bash
cp /etc/pip-configs/pip.conf.safe /etc/pip.conf
```

2. Restore the exact version pin in requirements.txt:

```bash
echo "internal-utils==1.0.0
data-processor==2.0.0" > requirements.txt
```

3. Reinstall from private registry only:

```bash
pip install --force-reinstall -r requirements.txt
```

4. Create a lockfile:

```bash
pip freeze > requirements.lock
```

## Why it works

- `--index-url` tells pip to ONLY check the specified registry
- `--extra-index-url` tells pip to check BOTH registries and pick the highest version
- The lockfile ensures exact versions are recorded for reproducible builds
