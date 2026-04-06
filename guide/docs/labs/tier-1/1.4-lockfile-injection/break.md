# Lab 1.4: Lockfile Injection

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

## Tampering with a Lockfile in a PR

### Step 1: Look at the "routine" PR

Open Gitea at `http://gitea:3000/weaklink/secure-app/pulls/1`, or inspect from the command line:

```bash
cd /tmp && git clone http://gitea:3000/weaklink/secure-app.git
cd secure-app
git log --oneline main..origin/update-deps
```

The commit message says "chore: update flask-utils to latest version" and claims it ran `pip-compile`.

### Step 2: See the diff

```bash
git diff main..origin/update-deps
```

The only change is in `requirements.txt`. The version is the same (`flask-utils==1.0.0`), but the **hash** is different. In a real lockfile with dozens of dependencies, this would be buried in hundreds of lines.

### Step 3: Check out the malicious branch and install

```bash
git checkout update-deps
cat requirements.txt
```

Compare:

```bash
cd /app/project
cp /tmp/secure-app/requirements.txt requirements.txt.malicious
diff <(grep "hash" /app/project/requirements.txt) <(grep "hash" requirements.txt.malicious)
```

The tampered hash corresponds to a backdoored `flask-utils` with a post-install hook.

### Step 4: Understand the attack surface

1. Lockfile diffs are HUGE and BORING. Reviewers skip them.
2. The commit message says "ran pip-compile". Looks legitimate.
3. The version number doesn't change. Only the hash.
4. CI/CD trusts the lockfile and installs whatever it says.
5. The backdoor runs at INSTALL time, not import time.

### Step 5: Check for compromise

```bash
ls -la /tmp/lockfile-pwned 2>&1
```

**Checkpoint:** You should now have the tampered lockfile identified, with a clear diff showing the hash swap between the legitimate and malicious versions.
