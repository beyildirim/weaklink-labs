# Lab 1.4: Lockfile Injection

A pull request titled "chore: update flask-utils to latest version" looks routine. The PR only changes the lockfile -- auto-generated, thousands of lines, nobody reads it carefully. But hidden in the diff, one hash has been swapped. The new hash points to a backdoored package. This lab teaches you how lockfile tampering works and how to catch it.

## Prerequisites

- Lab 1.1 completed
- Basic understanding of pip, npm, and version pinning

## Environment

| Container | Description |
|-----------|-------------|
| `lab-1.4-pypi` | A private PyPI server hosting the legitimate `flask-utils` package |
| `lab-1.4-gitea` | A Gitea instance with a repo containing a malicious PR |
| `lab-1.4-workstation` | Developer workstation with Python, Node.js, pip-tools |

Start the lab:

```bash
weaklink start 1.4
```

Connect to the workstation:

```bash
weaklink shell 1.4
```

Open Gitea in your browser: [http://gitea:3000](http://gitea:3000) (login: `developer` / `password123`)

---

## Phase 1: Understand

### Step 1: What is a lockfile?

A lockfile captures the **exact** versions and **cryptographic hashes** of every dependency in your project. It turns a loose dependency spec into a reproducible build.

**Without a lockfile** (loose requirements):

```
# requirements.in -- "I want flask-utils, any version"
flask-utils
```

**With a lockfile** (locked + hashed):

```
# requirements.txt -- "I want exactly this version, with exactly this content"
flask-utils==1.0.0 \
    --hash=sha256:abc123def456...
```

The hash ensures that even if someone publishes a different package with the same version number, pip will refuse to install it.

### Step 2: Generate a lockfile

```bash
cd /app/project
cat requirements.in
```

This file says we need `flask-utils`. Now lock it:

```bash
pip-compile --generate-hashes \
    --index-url http://pypi:8080/simple/ \
    --trusted-host pypi \
    requirements.in \
    --output-file requirements.txt
```

Look at the output:

```bash
cat requirements.txt
```

You'll see: the exact version (`flask-utils==1.0.0`), a SHA-256 hash of the package file, and a comment trail showing it was generated from `requirements.in`. This is the lockfile.

### Step 3: Install using the lockfile

```bash
pip install --require-hashes -r requirements.txt \
    --index-url http://pypi:8080/simple/ --trusted-host pypi
```

The `--require-hashes` flag means pip will verify the hash of every downloaded package against the lockfile. If the hash doesn't match, installation fails.

### Step 4: See the Node.js equivalent

```bash
cd /app/node-demo
cat package.json
```

This is like `requirements.in` -- it says "I want lodash ^4.17.21" (any compatible version).

```bash
npm install
cat package-lock.json | head -40
```

The `package-lock.json` is Node's lockfile. It pins the exact version, the resolved URL, and an integrity hash. Same concept, different ecosystem.

### Step 5: Why lockfiles matter

Without lockfiles:
- Different developers get different versions on different days
- A compromised version published today gets installed tomorrow
- You can't verify what you're running matches what was tested

With lockfiles:
- Everyone gets the exact same bytes
- Hashes catch any modification to the package content
- You can audit exactly what's in your dependency tree

---

## Phase 2: Break

### Step 1: Look at the "routine" PR

Open Gitea in your browser: [http://gitea:3000/developer/webapp/pulls/1](http://gitea:3000/developer/webapp/pulls/1)

Or inspect it from the command line:

```bash
cd /tmp && git clone http://developer:password123@gitea:3000/developer/webapp.git
cd webapp
```

Look at the PR branch:

```bash
git log --oneline main..origin/update-deps
```

The commit message says "chore: update flask-utils to latest version" and claims it ran `pip-compile`. Looks normal.

### Step 2: See the diff

```bash
git diff main..origin/update-deps
```

The only change is in `requirements.txt`. The version is the same (`flask-utils==1.0.0`), but the **hash** is different. In a real lockfile with dozens of dependencies, this change would be buried in hundreds of lines of hash updates.

### Step 3: Check out the malicious branch and install

```bash
git checkout update-deps
```

Look at the tampered lockfile:

```bash
cat requirements.txt
```

Now try installing from it:

```bash
cd /app/project
cp /tmp/webapp/requirements.txt requirements.txt.malicious
```

Compare the legitimate vs tampered lockfiles:

```bash
diff /app/project/requirements.txt.legitimate /app/project/requirements.txt.malicious 2>/dev/null || \
diff <(grep "hash" /app/project/requirements.txt) <(grep "hash" requirements.txt.malicious)
```

The hashes differ. The tampered hash corresponds to a backdoored version of `flask-utils` that contains a post-install hook.

### Step 4: Understand the attack surface

```bash
echo "
=== Why lockfile injection is so effective ===

1. Lockfile diffs are HUGE and BORING -- reviewers skip them
2. The commit message says 'ran pip-compile' -- looks legitimate
3. The version number doesn't change -- only the hash
4. CI/CD trusts the lockfile and installs whatever it says
5. The backdoor runs at INSTALL time, not at import time

This is why code review alone is not enough for supply chain security.
"
```

In the real world:
- A lockfile for a medium project can be 500+ lines
- Dependency update PRs come in daily (Dependabot, Renovate)
- Reviewers are trained to approve these quickly
- The attacker only needs to change a few characters

### Step 5: Check for compromise

If the backdoored package had been installed, it would have written a file:

```bash
ls -la /tmp/lockfile-pwned 2>&1
```

If the file exists, the attack succeeded. If not, the tampered lockfile wasn't installed with the backdoored wheel (the hash would need to match the actual backdoored package for `--require-hashes` to accept it).

---

## Phase 3: Defend

### Defense 1: Clean up any compromise

```bash
rm -f /tmp/lockfile-pwned
```

### Defense 2: Regenerate the lockfile from source

The key defense: **never trust a lockfile diff in a PR. Always regenerate from source.**

```bash
cd /app/project
pip-compile --generate-hashes \
    --index-url http://pypi:8080/simple/ \
    --trusted-host pypi \
    requirements.in \
    --output-file requirements.txt
```

This produces a lockfile from the trusted `requirements.in` file using the legitimate packages on PyPI. Compare it to the PR's version:

```bash
diff <(grep -v "^#" requirements.txt) <(grep -v "^#" requirements.txt.malicious 2>/dev/null) && \
    echo "Files match (no tampering)" || echo "FILES DIFFER -- tampering detected!"
```

### Defense 3: Set up a CI check

The `verify-lockfile.sh` script automates this check:

```bash
cat /app/project/verify-lockfile.sh
```

Test it against the legitimate lockfile:

```bash
cd /app/project
bash verify-lockfile.sh requirements.in requirements.txt
```

It should pass. Now test it against a tampered lockfile:

```bash
# Tamper with the lockfile by changing a hash character
cp requirements.txt requirements.txt.backup
sed -i 's/--hash=sha256:\([a-f0-9]\)/--hash=sha256:0/' requirements.txt
bash verify-lockfile.sh requirements.in requirements.txt
```

It should fail with "LOCKFILE MISMATCH DETECTED". Restore the good lockfile:

```bash
cp requirements.txt.backup requirements.txt
```

### Defense 4: Add this to your CI pipeline

In a real project, you would add this as a CI step:

```yaml
# .github/workflows/verify-lockfile.yml
name: Verify Lockfile
on: [pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - run: pip install pip-tools
      - run: |
          pip-compile --generate-hashes requirements.in -o /tmp/fresh.txt
          diff <(grep -v '^#' requirements.txt) <(grep -v '^#' /tmp/fresh.txt)
```

This check runs on every PR. If someone submits a lockfile that doesn't match a fresh `pip-compile` output, the CI fails.

### Verify your defenses

```bash
# From your host machine (not inside the container):
weaklink verify 1.4
```

The verification checks:
1. `/tmp/lockfile-pwned` does NOT exist
2. `verify-lockfile.sh` exists and is executable
3. The lockfile matches a fresh `pip-compile` output

---

## What You Learned

| Concept | Takeaway |
|---------|----------|
| **Lockfiles** | They pin exact versions and hashes to ensure reproducible, verified builds |
| **Lockfile injection** | Attackers swap hashes in lockfile PRs to point to backdoored packages |
| **Review blindness** | Lockfile diffs are large and "auto-generated" -- reviewers skip them |
| **Regeneration check** | Always regenerate lockfiles in CI and compare against the committed version |
| **Hash verification** | `--require-hashes` ensures pip only installs packages matching expected hashes |

## Real-World Impact

- **2021**: Researchers demonstrated lockfile injection against major open-source projects by submitting PRs that only modified `package-lock.json` or `yarn.lock`. Many were approved by maintainers.
- **2022**: The `ua-parser-js` npm package was hijacked. Projects without lockfile integrity checks pulled the compromised version automatically.
- **2023**: Multiple npm packages were found to contain lockfile-based attacks where `package-lock.json` pointed to a different registry than expected.
- **Event-Stream (2018)**: A maintainer gave access to an attacker who added a malicious dependency. Lockfile changes were approved in code review because they "looked like a normal dependency update."

## Further Reading

- [Lockfile Injection (Snyk Research)](https://snyk.io/blog/why-npm-lockfiles-can-be-a-security-blindspot-for-injecting-malicious-modules/)
- [pip-compile documentation](https://pip-tools.readthedocs.io/)
- [npm lockfile integrity](https://docs.npmjs.com/cli/v10/configuring-npm/package-lock-json)
- [PEP 665 -- Python Lockfiles](https://peps.python.org/pep-0665/)
- [SLSA Build Requirements](https://slsa.dev/spec/v1.0/requirements)
