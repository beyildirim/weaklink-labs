# Lab 1.1: How Dependency Resolution Works

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

## Exploiting Multi-Registry Resolution

### Step 1: Check what each registry has

List all packages on each registry. The grep extracts package names from the HTML index page:

```bash
curl -s http://pypi-private:8080/simple/ | grep -o 'href="[^"]*"'
curl -s http://pypi-public:8080/simple/ | grep -o 'href="[^"]*"'
```

The public registry has `internal-utils` version 99.0.0.

### Step 2: See how pip resolves with --extra-index-url

```bash
sed -i 's/internal-utils==1.0.0/internal-utils/' requirements.txt
pip install --force-reinstall -r requirements.txt
```

### Step 3: Verify the damage

```bash
pip show internal-utils
python app.py
```

Pip installed version **99.0.0** from the public registry. Why:

1. `--extra-index-url` tells pip to search **both** indexes
2. Pip picks the **highest version** across all sources
3. 99.0.0 > 1.0.0, so the public (attacker-controlled) version wins

This is the foundational issue behind **dependency confusion attacks** (covered in [Lab 1.2](../../1.2-dependency-confusion/)).

### Step 4: Understand the root cause

```bash
cat /etc/pip.conf
```

`extra-index-url` doesn't mean "fallback". It means "also check here." Pip merges results from all sources and picks the highest version.

**Checkpoint:** You should now have `internal-utils==99.0.0` installed from the public registry, and a clear understanding of why `extra-index-url` caused it.
