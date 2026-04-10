# Lab 2.5: Self-Hosted Runner Attacks

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Defend</span>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Ephemeral Runners and Isolation

The key lesson in this lab is simpler than the runner internals: untrusted PR code should not be allowed to leave persistent state behind on a shared machine. The concrete defenses here are:

1. clean the runner before each job
2. keep the CI workflow on the hardened path shipped with the lab
3. avoid running untrusted PR code on a long-lived host without isolation

### Fix 1: Restore a clean runner profile

```bash
cat > /runner/workspace/.bashrc << 'EOF'
# Clean runner profile
EOF
```

This removes the attacker-added startup hook from the Break phase.

### Fix 2: Install the shipped pre-job cleanup hook

```bash
cp /lab/src/scripts/pre-job-cleanup.sh /runner/hooks/pre-job.sh
chmod +x /runner/hooks/pre-job.sh
```

Open it and read the important parts:

```bash
cat /runner/hooks/pre-job.sh
```

This hook removes compromise markers, resets the runner profile, and cleans workspace state before the next job starts.

### Fix 3: Restore the hardened CI workflow

```bash
cd /repos/wl-webapp
git checkout main
cp /lab/src/repo/.gitea/workflows/ci-ephemeral.yml .gitea/workflows/ci.yml
cat .gitea/workflows/ci.yml
```

The important changes are:

1. PR-triggered execution is gone from the main workflow
2. jobs run in a disposable container
3. the workflow verifies clean state before building

### Fix 4: Commit and push

```bash
git add -A
git commit -m "Harden self-hosted runner workflow and cleanup hook"
git push origin main
```

### Key defenses

1. **Pre-job cleanup hooks** remove attacker state before the next build
2. **Container isolation** limits what a build can persist on the host
3. **Main CI should not run untrusted PR code on the long-lived runner**
4. **Ephemeral or disposable execution is the operational goal**, even if this lab simulates it with cleanup plus isolation
