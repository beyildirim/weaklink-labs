# Lab 1.2: Dependency Confusion

In February 2021, security researcher Alex Birsan published a technique that allowed him to execute code inside Microsoft, Apple, PayPal, Tesla, Uber, and dozens of other companies -- just by publishing packages to public PyPI with the same names as their internal packages.

The attack is simple: if a company uses an internal package called `acme-auth` from their private registry but also has `--extra-index-url https://pypi.org/simple/` in their pip config, an attacker can publish `acme-auth==99.0.0` to public PyPI. Pip picks the higher version, runs the attacker's `setup.py`, and the company is compromised.

In this lab, you are a developer at ACME Corp. You will see the attack happen, then defend against it.

## Prerequisites

- Lab 1.1 completed (Dependency Resolution)
- Understanding of `--index-url` vs `--extra-index-url` from Lab 1.1

## Environment

| Service | Description |
|---------|-------------|
| `workstation` | ACME Corp developer machine with Python 3.11 |
| `private-pypi` | ACME Corp private PyPI server with `acme-auth==1.0.0` |
| `public-pypi` | Simulated public PyPI with attacker's `acme-auth==99.0.0` |

Connect to the workstation:

```bash
weaklink shell 1.2
```

## Phase 1: Understand

### Step 1: Explore the corporate app

```bash
cat /app/requirements.txt
cat /app/app.py
```

The app depends on `acme-auth==1.0.0`, an internal authentication library.

### Step 2: Check the private registry

```bash
curl -s http://private-pypi:8080/simple/ | grep -o 'href="[^"]*"'
curl -s http://private-pypi:8080/simple/acme-auth/
```

The legitimate `acme-auth 1.0.0` is on the private registry.

### Step 3: Check the public registry

```bash
curl -s http://public-pypi:8080/simple/ | grep -o 'href="[^"]*"'
curl -s http://public-pypi:8080/simple/acme-auth/
```

There IS an `acme-auth` on the public registry -- version 99.0.0. This is the attacker's package. In the real world, the attacker found the internal package name (from a leaked `requirements.txt`, a job posting, or a public GitHub repo) and published a higher version.

### Step 4: Check pip configuration

```bash
cat /etc/pip.conf
```

Notice: `extra-index-url` points to the public registry. This means pip checks **both** registries and picks the highest version.

### Step 5: Install and test (safe for now)

Because the requirements pin `acme-auth==1.0.0` exactly, the first install is safe:

```bash
pip install -r requirements.txt
python app.py
```

The app works. No compromise. The exact version pin (`==1.0.0`) protects you -- for now.

### Step 6: Verify no compromise

```bash
bash /app/scripts/check-compromise.sh
```

Clean. But the danger is lurking.

## Phase 2: Break

This is where it gets real. An attacker has already published `acme-auth==99.0.0` to the public registry.

### Step 1: Simulate a common developer action

A developer loosens the version pin (maybe to get the "latest" version, or during a dependency upgrade):

```bash
# Change ==1.0.0 to just acme-auth (any version)
sed -i 's/acme-auth==1.0.0/acme-auth/' requirements.txt
cat requirements.txt
```

### Step 2: Reinstall

```bash
pip install --force-reinstall -r requirements.txt
```

Watch the output carefully. Pip finds version 99.0.0 on the public registry and installs it because it's higher than 1.0.0.

**The malicious `setup.py` executes during installation.** Code runs before you ever import the package.

### Step 3: Check for compromise

```bash
cat /tmp/dependency-confusion-pwned
```

COMPROMISED. The malicious `setup.py` wrote this file during `pip install`. In a real attack, this could have:

- Exfiltrated environment variables (`AWS_SECRET_ACCESS_KEY`, `CI_TOKEN`, etc.)
- Downloaded and executed a reverse shell
- Modified other installed packages
- Sent source code to the attacker's server

### Step 4: Run the app to see runtime impact

```bash
python app.py
```

The app detects the compromise. The malicious package also replaces the `authenticate()` function with one that logs credentials.

### Step 5: Verify with the check script

```bash
bash /app/scripts/check-compromise.sh
```

### Step 6: Understand why it worked

```bash
pip show acme-auth
```

Version 99.0.0. The attack worked because:

1. `--extra-index-url` makes pip search **both** registries
2. Pip picks the **highest version** across all sources
3. The attacker's 99.0.0 beats the legitimate 1.0.0
4. `setup.py` runs arbitrary code **during installation** (not import)
5. Even if you notice later, the damage is already done

This is exactly how Alex Birsan compromised 35+ companies and earned over $130,000 in bug bounties.

## Phase 3: Defend

### Fix 1: Use --index-url (not --extra-index-url)

```bash
# Remove the compromise marker first
rm -f /tmp/dependency-confusion-pwned

# Switch to the safe pip config
cp /etc/pip-configs/pip.conf.safe /etc/pip.conf
cat /etc/pip.conf
```

Now pip ONLY knows about the private registry.

### Fix 2: Restore and reinstall

```bash
# Restore the exact version pin
echo "acme-auth==1.0.0" > requirements.txt

# Uninstall the malicious version
pip uninstall -y acme-auth

# Install from private registry only
pip install -r requirements.txt
```

### Fix 3: Verify the defense

```bash
# Check the version
pip show acme-auth

# Run the app
python app.py

# Check for compromise
bash /app/scripts/check-compromise.sh
```

You should see:
- Version 1.0.0 installed
- No compromise detected
- `/tmp/dependency-confusion-pwned` does not exist

### Additional defenses (discussion)

Beyond switching to `--index-url`, organizations should also:

1. **Use `--require-hashes`**: Pin packages to their exact SHA256 hashes. Even if an attacker publishes the same name+version, the hash won't match.

   ```bash
   # Generate hashes
   pip hash /path/to/acme-auth-1.0.0.tar.gz

   # In requirements.txt:
   # acme-auth==1.0.0 --hash=sha256:abc123...
   ```

2. **Register internal package names on public PyPI**: Claim the namespace so attackers can't. Even an empty package with `0.0.1` blocks attackers from using the name.

3. **Use a repository manager** (Artifactory, Nexus): These can proxy public PyPI and be configured to prefer private packages by name pattern.

4. **Scope packages**: Some ecosystems support scoped packages (npm's `@acme/auth`). Python doesn't have native namespaces, but naming conventions like `acme-*` help.

### Step 4: Final verification

Exit the workstation and verify:

```bash
exit
weaklink verify 1.2
```

## What You Learned

1. **Dependency confusion is a real attack** -- it compromised Microsoft, Apple, PayPal, and 35+ other companies in 2021.
2. **`setup.py` runs during install** -- malicious code executes before you ever `import` the package. The damage is done before you can detect it.
3. **`--extra-index-url` is the root cause** -- it tells pip to search multiple registries and pick the highest version, regardless of source.
4. **`--index-url` is the fix** -- pointing pip to only the private registry eliminates the attack vector entirely.
5. **Version pins alone are not enough** -- they help, but a developer loosening a pin (or running `pip install --upgrade`) reopens the vulnerability.
6. **Defense in depth matters** -- combine `--index-url`, exact version pins, hash verification, and namespace claiming.

## Further Reading

- [Alex Birsan: Dependency Confusion (original blog post)](https://medium.com/@alex.birsan/dependency-confusion-4a5d60fec610)
- [Microsoft: 3 Ways to Mitigate Risk When Using Private Package Feeds](https://azure.microsoft.com/en-us/resources/3-ways-to-mitigate-risk-using-private-package-feeds/)
- [pip documentation: --extra-index-url](https://pip.pypa.io/en/stable/cli/pip_install/#cmdoption-extra-index-url)
- [OWASP: Supply Chain Attacks](https://owasp.org/www-community/attacks/Supply_Chain_Attack)
- [Snyk: Dependency Confusion Explained](https://snyk.io/blog/detect-prevent-dependency-confusion-attacks-npm-supply-chain-security/)
