# Lab 1.4: Lockfile Injection

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step upcoming">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## What Lockfiles Are and Why They Matter

Focus on the trust model as you go. A lockfile is not just dependency metadata. It is an integrity promise that CI and developers are expected to trust without re-reading every package.

### Step 1: What is a lockfile?

A lockfile captures the **exact** versions and **cryptographic hashes** of every dependency. It turns a loose dependency spec into a reproducible build.

**Without a lockfile** (loose requirements):

```
# requirements.in
flask-utils
```

**With a lockfile** (locked + hashed):

```
# requirements.txt
flask-utils==1.0.0 \
    --hash=sha256:abc123def456...
```

The hash ensures that even if someone publishes a different package with the same version number, pip will refuse to install it.

### Step 2: Generate a lockfile

```bash
cd /app/project
cat requirements.in
```

Lock it:

```bash
pip-compile --generate-hashes \
    --index-url http://pypi-private:8080/simple/ \
    --trusted-host pypi-private \
    requirements.in \
    --output-file requirements.txt
```

```bash
cat requirements.txt
```

Exact version (`flask-utils==1.0.0`), SHA-256 hash, and a comment trail showing it was generated from `requirements.in`.

### Step 3: Install using the lockfile

```bash
pip install --require-hashes -r requirements.txt \
    --index-url http://pypi-private:8080/simple/ --trusted-host pypi-private
```

`--require-hashes` verifies the hash of every downloaded package. If the hash doesn't match, installation fails.
