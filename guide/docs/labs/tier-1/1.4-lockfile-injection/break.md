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

Focus on the reviewer failure as you go. This lab is about spotting a malicious dependency change before it reaches a build, not about memorizing hash syntax.

### Step 1: Look at the "routine" PR

Use the browser terminal as the canonical path for this lab. The seeded repository is `developer/webapp`:

```bash
cd /tmp && git clone http://gitea:3000/developer/webapp.git
cd webapp
git log --oneline main..origin/update-deps
```

If your setup also exposes Gitea on the host, the PR is `http://localhost:3000/developer/webapp/pulls/1` and the login is `developer` / `password123`.

The commit message says "chore: update flask-utils to latest version" and claims it ran `pip-compile`.

### Step 2: See the diff

```bash
git diff main..origin/update-deps
```

The only change is in `requirements.txt`. The version is the same (`flask-utils==1.0.0`), but the **hash** is different. In a real lockfile with dozens of dependencies, this would be buried in hundreds of lines.

### Step 3: Check out the malicious branch and inspect it

```bash
git checkout update-deps
cat requirements.txt
```

Compare:

```bash
cd /app/project
cp /tmp/webapp/requirements.txt requirements.txt.malicious
diff <(grep "hash" /app/project/requirements.txt) <(grep "hash" requirements.txt.malicious)
```

The tampered hash corresponds to a backdoored `flask-utils` with a post-install hook.

### Step 4: Understand the attack surface

1. Lockfile diffs are HUGE and BORING. Reviewers skip them.
2. The commit message says "ran pip-compile". Looks legitimate.
3. The version number doesn't change. Only the hash.
4. CI/CD trusts the lockfile and installs whatever it says.
5. The backdoor runs at INSTALL time, not import time.

### Step 5: Understand where compromise would happen

```bash
ls -la /tmp/lockfile-pwned 2>&1
```

At this point, there should be no compromise marker yet. That is the point. You are catching the attack at review time, before CI installs from the tampered lockfile.

**Checkpoint:** You should now have the tampered lockfile identified, a clear diff showing the hash swap, and a clear understanding that the real payload would execute later during automated installation.
