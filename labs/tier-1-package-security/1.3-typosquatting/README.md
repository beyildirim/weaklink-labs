# Lab 1.3: Typosquatting

> Legacy note: The canonical learner-facing version of this lab lives in the browser guide. Start the platform with `make start`, open the guide, and use the built-in terminal. Treat this README as a secondary local reference.

A developer installs `reqeusts` instead of `requests`. The package works perfectly, but it also steals their secrets. This lab demonstrates one of the most common and effective supply chain attacks: typosquatting.

## Prerequisites

- Lab 1.1 completed
- Basic understanding of pip and Python packages

## Environment

| Container | Description |
|-----------|-------------|
| `lab-1.3-pypi` | A private PyPI server with both legitimate and typosquatted packages |
| `lab-1.3-workstation` | A developer workstation with Python, pip, and a simulated secret |

Start the lab:

```bash
make start
```

Use the built-in browser terminal:

```bash
make start
```

---

## Phase 1: Understand

### Step 1: Explore the PyPI registry

List all packages available on the private PyPI server:

```bash
curl -s http://pypi:8080/simple/ | grep -oP '(?<=href="/simple/)[^/]+'
```

You should see two packages: `requests` and `reqeusts`.

### Step 2: Install the legitimate package

```bash
pip install --index-url http://pypi:8080/simple/ --trusted-host pypi requests
```

Test it:

```bash
python3 -c "import requests; print(f'Package: {requests.__title__} v{requests.__version__}')"
```

It works. This is the real (simulated) `requests` library.

### Step 3: Think about the scale

Consider:
- PyPI has over **500,000** packages
- Anyone can register a package name. There is no verification of identity or intent
- Package names are just strings. `requests` vs `reqeusts` vs `request` vs `requets`. They all look similar at a glance

Real typosquatting packages caught in the wild:

| Typosquat | Legitimate | Technique |
|-----------|-----------|-----------|
| `python3-dateutil` | `python-dateutil` | Prefix confusion |
| `colourama` | `colorama` | British spelling |
| `jeIlyfish` (capital I) | `jellyfish` (lowercase L) | Homoglyph |
| `python-mongo` | `pymongo` | Naming convention |
| `noblesse` | (standalone malware) | Plausible-sounding name |

In 2023, researchers found **over 5,000** typosquatting packages on PyPI in a single scan.

### Step 4: Compare the two packages

Look at the package files on the PyPI server directly:

```bash
curl -s http://pypi:8080/simple/requests/
curl -s http://pypi:8080/simple/reqeusts/
```

Both are version 2.31.0. Both have the same description. A developer glancing at these would see nothing suspicious.

---

## Phase 2: Break

### Step 1: The developer's mistake

There is an install script that a developer wrote. Look at it:

```bash
cat /app/scripts/install_deps.sh
```

Can you spot the typo? It installs `reqeusts` instead of `requests`.

### Step 2: Check the environment

Before running the script, notice the developer has a secret API key set:

```bash
echo $SECRET_API_KEY
```

This simulates any secret a developer might have in their environment: AWS keys, database credentials, API tokens.

### Step 3: Run the install script

First, uninstall the legitimate package so we start clean:

```bash
pip uninstall requests -y 2>/dev/null
```

Now run the developer's script:

```bash
bash /app/scripts/install_deps.sh
```

It completes without errors. The developer thinks everything is fine.

### Step 4: Test the package

The typosquatted package wraps the legitimate one, so it actually works:

```bash
python3 -c "
import reqeusts
print(f'Package: {reqeusts.__title__} v{reqeusts.__version__}')
resp = reqeusts.get('http://pypi:8080/simple/')
print(f'HTTP GET -> {resp.status_code}')
print('All tests pass!')
"
```

Everything works. The developer's code runs, tests pass, no errors anywhere.

### Step 5: Find the damage

But look what happened during installation:

```bash
cat /tmp/typosquat-exfil
```

Your `SECRET_API_KEY`, username, home directory, and hostname were all written to this file. In a real attack, this data would be sent to an attacker's server during `pip install`, before the developer even writes a single line of code.

### Step 6: Understand why this is devastating

```bash
python3 -c "
import reqeusts
# The developer uses it normally. Code review sees 'reqeusts.get(...)'.
# Maybe a reviewer notices the typo. Maybe not.
# But the damage is already done. The secret was stolen at INSTALL time.
# Not at import time. Not at runtime. At install time.
print('The secret was stolen during pip install, not during import.')
print('By the time you run this code, your keys are already compromised.')
"
```

The attack vector is the `setup.py` post-install hook. Look at it:

```bash
pip download --no-deps --dest /tmp/pkg-inspect reqeusts -i http://pypi:8080/simple/ --trusted-host pypi 2>/dev/null
cd /tmp/pkg-inspect && unzip -q *.whl -d extracted 2>/dev/null || python3 -m zipfile -e *.whl extracted
find /tmp/pkg-inspect/extracted -name "*.py" -exec grep -l "exfil\|secret\|environ" {} \;
```

---

## Phase 3: Defend

### Defense 1: Remove the typosquatted package

```bash
pip uninstall reqeusts -y
rm -f /tmp/typosquat-exfil
```

Verify the exfiltration file is gone:

```bash
ls -la /tmp/typosquat-exfil 2>&1
```

### Defense 2: Install the correct package

```bash
pip install --index-url http://pypi:8080/simple/ --trusted-host pypi requests
```

### Defense 3: Create a pinned requirements.txt

Never install packages by typing names manually. Use a requirements file with exact version pins:

```bash
cat > /app/requirements.txt << 'EOF'
requests==2.31.0
EOF
```

In production, you would also add hashes for full integrity verification:

```bash
# Example of hash-pinned requirements (the hash below is illustrative):
# pip install --require-hashes -r requirements.txt
# requests==2.31.0 --hash=sha256:abc123...
```

### Defense 4: Validate against an allowlist

Check installed packages against an approved list:

```bash
bash /app/scripts/validate_packages.sh /app/allowlist.txt
```

If any unauthorized package is installed, this script flags it.

### Defense 5: Run pip-audit

```bash
pip-audit 2>/dev/null || echo "pip-audit found no known vulnerabilities"
```

Note: `pip-audit` checks against known vulnerability databases. It catches packages with reported CVEs but may not catch brand-new typosquatting attacks. That is why defense-in-depth (allowlists + pinning + review) matters.

### Continue the lab

Stay in the workstation and confirm the fix directly:

```bash
pip show requests
test ! -f /tmp/typosquat-exfil && echo clean
cat /app/requirements.txt
```

---

## What You Learned

| Concept | Takeaway |
|---------|----------|
| **Typosquatting** | Attackers register package names that are one keystroke away from popular packages |
| **Post-install hooks** | `setup.py` can run arbitrary code during `pip install`, before you ever import the package |
| **Functional wrappers** | Malicious packages can wrap the real one, passing all tests while exfiltrating data |
| **Version pinning** | Exact version pins in `requirements.txt` prevent accidental installation of wrong packages |
| **Allowlists** | Validating installed packages against an approved list catches unauthorized packages |

## Real-World Impact

- **2017**: `python3-dateutil` was uploaded to PyPI, targeting the hugely popular `python-dateutil`. It contained credential-stealing code.
- **2021**: Researchers published "An Empirical Study of Typosquatting in the Python Package Index" finding thousands of squatting candidates.
- **2022**: `ctx` package on PyPI was compromised and used to steal environment variables, the exact technique shown in this lab.
- **2023**: Multiple PyPI packages (`colorslib`, `httpslib`, `libhttps`) were found with `setup.py` hooks that stole secrets.

## Further Reading

- [PyPI Typosquatting Research (2023)](https://blog.phylum.io/pypi-malware-replaces-crypto-addresses-in-developers-clipboard)
- [Typosquatting in Python Ecosystem](https://arxiv.org/abs/2005.09535)
- [pip-audit documentation](https://github.com/pypa/pip-audit)
- [PEP 685: Comparison of Lockfiles](https://peps.python.org/pep-0685/)
- [OWASP Supply Chain Risks](https://owasp.org/www-project-top-10-ci-cd-security-risks/)
