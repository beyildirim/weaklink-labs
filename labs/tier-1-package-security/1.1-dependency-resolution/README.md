# Lab 1.1: How Dependency Resolution Works

> Legacy note: The canonical learner-facing version of this lab lives in the browser guide. Start the platform with `make start`, open the guide, and use the built-in terminal. Treat this README as a secondary local reference.

When you run `pip install`, pip doesn't just download one package. It resolves an entire dependency tree. Understanding how this works is essential because **every supply chain attack exploits something about this process**.

This lab gives you a private PyPI registry, a public PyPI registry, and a Python app with dependencies. You'll see exactly how pip decides which package version to install and from which source.

## Prerequisites

- Lab 0.2 completed (Package Managers basics)
- Basic familiarity with `pip install` and `requirements.txt`

## Environment

| Service | Description |
|---------|-------------|
| `workstation` | Your developer machine with Python 3.11 and pip |
| `pypi-private` | Corporate internal PyPI server with legitimate packages |
| `pypi-public` | Simulated public PyPI (starts with a higher-version fake package) |

Use the built-in browser terminal:

```bash
make start
```

## Phase 1: Understand

### Step 1: Look at your application

```bash
cat /app/requirements.txt
```

You have an app that depends on `internal-utils==1.0.0` and `data-processor==2.0.0`. These are internal company packages hosted on the private registry.

### Step 2: Check pip configuration

```bash
cat /etc/pip.conf
```

Notice the configuration:
- `index-url` points to the **private** registry
- `extra-index-url` points to the **public** registry

This is a common (and dangerous) pattern in corporate environments.

### Step 3: Install dependencies

```bash
pip install -r requirements.txt
```

Watch the output. Pip resolves all packages from the private registry. Everything works.

### Step 4: Visualize the dependency tree

```bash
pipdeptree
```

You can see the full tree: `data-processor` depends on `internal-utils`, which depends on `logging-helper`. This is **dependency resolution**. Pip figures out the entire chain.

### Step 5: Test the app

```bash
python app.py
```

It should print that version 1.0.0 of `internal-utils` is installed.

### Step 6: Explore lockfiles

Generate a lockfile:

```bash
pip freeze
```

This shows every installed package at its exact version. This is what a "lockfile" captures. Without it, the same `requirements.txt` can produce different results at different times.

### Step 7: Experiment with version pins

Edit requirements.txt to change the version pin:

```bash
# Change internal-utils==1.0.0 to internal-utils>=1.0.0
sed -i 's/internal-utils==1.0.0/internal-utils>=1.0.0/' requirements.txt
```

Now reinstall:

```bash
pip install --force-reinstall -r requirements.txt
```

What version did pip install? When you use `>=` instead of `==`, pip looks for the **highest available version across ALL configured registries**.

Check:

```bash
pip show internal-utils
python app.py
```

If you got version 99.0.0, you just saw the problem with `--extra-index-url`.

**Reset the requirements before continuing:**

```bash
sed -i 's/internal-utils>=1.0.0/internal-utils==1.0.0/' requirements.txt
pip install --force-reinstall -r requirements.txt
```

## Phase 2: Break

Now you understand normal resolution. Let's see where it goes wrong.

### Step 1: Check what each registry has

```bash
# What's on the private registry?
curl -s http://pypi-private:8080/simple/ | grep -o 'href="[^"]*"'

# What's on the public registry?
curl -s http://pypi-public:8080/simple/ | grep -o 'href="[^"]*"'
```

The public registry has `internal-utils` version 99.0.0, a fake higher version.

### Step 2: See how pip resolves with --extra-index-url

With the current config (`extra-index-url`), pip checks **both** registries and picks the highest version:

```bash
# Loosen the pin to allow any version
sed -i 's/internal-utils==1.0.0/internal-utils/' requirements.txt

# Reinstall
pip install --force-reinstall -r requirements.txt
```

### Step 3: Verify the damage

```bash
pip show internal-utils
python app.py
```

Pip installed version **99.0.0** from the public registry, even though your private registry has the legitimate 1.0.0. This is because:

1. `--extra-index-url` tells pip to search **both** indexes
2. Pip picks the **highest version** across all sources
3. 99.0.0 > 1.0.0, so the public (attacker-controlled) version wins

This is the foundational issue behind **dependency confusion attacks** (covered in Lab 1.2).

### Step 4: Understand the root cause

```bash
cat /etc/pip.conf
```

The problem is `extra-index-url`. It doesn't mean "fallback"; it means "also check here." Pip merges results from all sources and picks the highest version.

## Phase 3: Defend

### Step 1: Fix the pip configuration

Replace the dangerous config with the safe one:

```bash
cp /etc/pip-configs/pip.conf.safe /etc/pip.conf
cat /etc/pip.conf
```

Now pip only knows about the private registry. The public registry is not consulted at all.

### Step 2: Fix and reinstall

```bash
# Restore the exact pin
sed -i 's/^internal-utils$/internal-utils==1.0.0/' requirements.txt

# Reinstall from private registry only
pip install --force-reinstall -r requirements.txt
```

### Step 3: Verify correct version

```bash
pip show internal-utils
python app.py
```

You should see version 1.0.0, the legitimate version from the private registry.

### Step 4: Create a lockfile

```bash
pip freeze > requirements.lock
cat requirements.lock
```

This lockfile captures the exact versions of every installed package. Commit this to version control. It ensures that every developer and CI system installs the same versions.

### Step 5: Verify the defense

```bash
# Continue with the guide flow from the browser.
```

## What You Learned

1. **Dependency resolution is a tree.** One package can pull in many others, each with their own version constraints.
2. **`--extra-index-url` is dangerous.** It tells pip to merge results from multiple sources and pick the highest version, regardless of which source it comes from.
3. **`--index-url` is safer.** It tells pip to only use one source.
4. **Lockfiles freeze versions.** `pip freeze` captures exact versions so builds are reproducible and resistant to new malicious versions appearing.
5. **Version pins matter.** `==1.0.0` is strict; `>=1.0.0` opens the door to unexpected upgrades.

## Further Reading

- [pip documentation: Configuration](https://pip.pypa.io/en/stable/topics/configuration/)
- [pip documentation: --extra-index-url](https://pip.pypa.io/en/stable/cli/pip_install/#cmdoption-extra-index-url)
- [Python Packaging: Dependency Resolution](https://packaging.python.org/en/latest/specifications/dependency-specifiers/)
- [Tidelift: The danger of --extra-index-url](https://blog.tidelift.com/the-danger-of-extra-index-url-in-pip)
