# Lab 1.2: Dependency Confusion

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

## The Corporate Package Setup

WeakLink Corp has an internal Python package called `wl-auth` on their private registry. Your job is to understand how pip resolves this package and where the danger lies.

### Step 1: Explore the corporate app

Look at what the app depends on and how it uses the internal package:

```bash
cat /app/requirements.txt
cat /app/app.py
```

The app depends on `wl-auth==1.0.0`, an internal authentication library.

### Step 2: Check the private registry

See what packages live on the corporate registry:

```bash
curl -s http://pypi-private:8080/simple/ | grep -o 'href="[^"]*"'
curl -s http://pypi-private:8080/simple/wl-auth/
```

### Step 3: Check the public registry

Now check the public registry. An attacker found the internal package name (from a leaked `requirements.txt`, a job posting, or a public repo) and published a higher version:

```bash
curl -s http://pypi-public:8080/simple/ | grep -o 'href="[^"]*"'
curl -s http://pypi-public:8080/simple/wl-auth/
```

`wl-auth` version 99.0.0 on the public registry.

### Step 4: Check pip configuration

This is the root cause. Look at how pip is configured:

```bash
cat /etc/pip.conf
```

`extra-index-url` points to the public registry. This tells pip to check **both** registries and pick the highest version across all sources.

### Step 5: Install and test (safe for now)

The exact version pin (`==1.0.0`) protects you:

```bash
pip install -r requirements.txt
python app.py
```

### Step 6: Verify no compromise

```bash
bash /app/scripts/check-compromise.sh
```

Clean. But the danger is lurking. The version pin is the only thing between you and a full compromise. In the next phase, you will see what happens when that pin is loosened.
