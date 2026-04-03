# Lab 0.2: How Package Managers Work

**Time:** ~25 minutes | **Difficulty:** Beginner | **Prerequisites:** Lab 0.1

Every modern application is built from dozens or hundreds of third-party packages. When you run `pip install`, you are downloading and executing code written by strangers. Package managers make this convenient -- but convenience is the enemy of security.

In this lab you will see how `pip install` works, then install a package with a malicious `setup.py` that runs arbitrary code on your machine, then defend against it using hash verification.

---

## Environment

This lab runs a **local PyPI server** (a private package repository, like a mini version of pypi.org) and a workspace container with Python and pip.

| Service       | URL / Access                |
|---------------|-----------------------------|
| Local PyPI    | http://localhost:8080       |
| PyPI browser  | http://localhost:8080/simple/ |

## Starting the Lab

```bash
cd labs/tier-0-foundations/0.2-package-managers
docker compose up -d
```

Wait about 10-15 seconds for the packages to build. Check that everything is running:

```bash
docker compose ps
```

You should see `pypi` running (healthy) and `workspace` running. The `build-packages` container will have exited (normal -- it only runs once to prepare the packages).

Open a shell inside the workspace container:

```bash
docker compose exec workspace bash
```

You are now inside the workspace container. All commands below run here.

---

## Phase 1: UNDERSTAND -- How pip install Works

**Goal:** See what actually happens when you install a Python package.

### Step 1: Browse the local package server

The local PyPI server has two packages. Browse them:

```bash
curl -s http://pypi:8080/simple/ | grep -o 'href="[^"]*"'
```

You should see links for `safe-utils` and `malicious-utils`.

### Step 2: Install a safe package

```bash
pip install --index-url http://pypi:8080/simple/ --trusted-host pypi safe-utils
```

**What just happened?** pip did the following:
1. Connected to the package server (our local PyPI)
2. Found the package `safe-utils`
3. Downloaded the package archive (a `.tar.gz` file)
4. Extracted it
5. Ran `setup.py install` to install it

### Step 3: See where the package was installed

```bash
pip show safe-utils
```

This shows you the package metadata: name, version, location on disk. Look at the `Location` field -- that is where Python stores installed packages.

### Step 4: Use the package

```bash
python -c "from safe_utils import greet; print(greet('Security Analyst'))"
```

You should see: `Hello, Security Analyst!`

### Step 5: Download a package without installing it

Let's look at what is inside a package before we install it:

```bash
mkdir -p /workspace/inspect
pip download --index-url http://pypi:8080/simple/ --trusted-host pypi \
    --no-deps -d /workspace/inspect safe-utils
```

Now extract and look inside:

```bash
cd /workspace/inspect
tar xzf safe-utils-*.tar.gz
ls safe-utils-1.0.0/
```

You should see `setup.py`, `safe_utils.py`, and `PKG-INFO`.

### Step 6: Read the setup.py

```bash
cat safe-utils-1.0.0/setup.py
```

This is the file that pip executes when installing. For `safe-utils`, it just defines the package name, version, and modules. **But setup.py is a full Python script -- it can do anything.**

---

## Phase 2: BREAK -- Malicious Code in setup.py

**Goal:** See what happens when a package has a malicious `setup.py`.

### Step 1: First, verify /tmp/pwned does not exist

```bash
ls -la /tmp/pwned 2>&1
```

You should see "No such file or directory". Good -- nothing has been compromised yet.

### Step 2: Look at the malicious package (before installing)

Let's download and inspect it first:

```bash
cd /workspace/inspect
pip download --index-url http://pypi:8080/simple/ --trusted-host pypi \
    --no-deps -d . malicious-utils
tar xzf malicious-utils-*.tar.gz
cat malicious-utils-1.0.0/setup.py
```

Read this carefully. The `setup.py` contains:
- Normal package setup code (name, version, etc.)
- **A malicious payload** that writes to `/tmp/pwned`

In a real attack, this payload could steal API keys, install backdoors, or exfiltrate source code. The malicious code runs **during installation**, before the package is even usable.

### Step 3: Install the malicious package

```bash
pip install --index-url http://pypi:8080/simple/ --trusted-host pypi malicious-utils
```

You will see a warning message printed during installation. In a real attack, there would be no warning -- the malicious code would run silently.

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

**The package's `setup.py` ran arbitrary code on your system the moment you ran `pip install`.** You didn't import it. You didn't run it. Just installing it was enough.

### Step 5: Think about scale

On the real PyPI (pypi.org), there are over 500,000 packages. Any one of them could have a malicious `setup.py`. Typosquatting attacks (Lab 1.3) create packages with names like `reqeusts` instead of `requests`, hoping people make typos.

---

## Phase 3: DEFEND -- Hash Verification with --require-hashes

**Goal:** Use pip's hash checking to ensure you only install packages you have explicitly verified.

### Step 1: Clean up from the attack

```bash
pip uninstall -y malicious-utils safe-utils 2>/dev/null
rm -f /tmp/pwned
```

### Step 2: Get the hash of the safe package

When you verified a package is safe (by reading its source code, checking its signatures, etc.), you record its hash. This hash is a fingerprint of the exact package file.

```bash
SAFE_HASH=$(pip hash /workspace/inspect/safe-utils-1.0.0.tar.gz 2>/dev/null | grep sha256 | cut -d: -f2)
echo "Safe package hash: sha256:${SAFE_HASH}"
```

If the above does not work (older pip), calculate it manually:

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
    --index-url http://pypi:8080/simple/ --trusted-host pypi \
    -r /workspace/requirements.txt
```

This should succeed -- the hash matches.

### Step 5: Try to install the malicious package with wrong hash

Now try to install the malicious package, but with the safe package's hash:

```bash
cat > /workspace/requirements-evil.txt << EOF
malicious-utils==1.0.0 --hash=sha256:${SAFE_HASH}
EOF

pip install --require-hashes \
    --index-url http://pypi:8080/simple/ --trusted-host pypi \
    -r /workspace/requirements-evil.txt 2>&1 || true
```

pip will **refuse** to install it because the hash does not match. You should see an error like:
```
ERROR: THESE PACKAGES DO NOT MATCH THE HASHES FROM THE REQUIREMENTS FILE.
```

### Step 6: Verify the defense worked

```bash
ls -la /tmp/pwned 2>&1
```

You should see "No such file or directory". The malicious package was never installed, so its `setup.py` never ran.

### Step 7: Verify with the lab checker

Exit the workspace container:

```bash
exit
```

Run the verification script:

```bash
bash verify.sh
```

---

## What You Learned

| Concept | Why It Matters for Supply Chain Security |
|---------|------------------------------------------|
| **pip install runs setup.py** | Installation = code execution. You are trusting the package author with your system. |
| **setup.py is arbitrary Python** | It can do anything: steal secrets, install backdoors, modify other packages |
| **Packages come from registries** | Public registries (pypi.org, npmjs.com) are trusted by default but not verified |
| **Hash checking pins exact content** | `--require-hashes` ensures you get the exact bytes you verified, not a tampered version |
| **Defense requires explicit verification** | You must know what you are installing and verify it before trusting it |

## Real-World Examples

- **event-stream (2018):** A popular npm package was taken over by an attacker who added a malicious dependency that stole cryptocurrency wallet keys.
- **ua-parser-js (2021):** A compromised npm package with 8 million weekly downloads had crypto-mining malware injected into it.
- **PyPI malware campaigns (ongoing):** Researchers regularly find hundreds of malicious packages on PyPI using typosquatting and setup.py payloads.

## Further Reading

- [pip install --require-hashes documentation](https://pip.pypa.io/en/stable/topics/secure-installs/)
- [PyPI Malware: What You Need to Know](https://blog.phylum.io/pypi-malware/)
- [OWASP Dependency Check](https://owasp.org/www-project-dependency-check/)
