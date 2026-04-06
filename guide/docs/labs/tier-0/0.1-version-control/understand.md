# Lab 0.1: How Version Control Works

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

## Exploring a Git Repository

### Step 1: Clone the repository

```bash
cd /workspace
git clone http://weaklink:weaklink@gitea:3000/weaklink/web-app.git
cd web-app
```

### Step 2: Look at the commit history

```bash
git log --oneline
```

4 commits on `main`.

### Step 3: Inspect a specific commit

Find the "Load config from YAML file" commit ID, then:

```bash
git show <commit-id>
```

### Step 4: Diff between two commits

Compare every change from the first commit to now. This shows the full evolution of the codebase:

```bash
git diff $(git rev-list --max-parents=0 HEAD) HEAD
```

### Step 5: Explore branches

```bash
git branch -a
git checkout feature/add-logging
git log --oneline
git diff main..feature/add-logging
git checkout main
```

The feature branch has one extra commit compared to main.

### Step 6: Inspect the build script

```bash
cat build.sh
```

Anyone who runs `./build.sh` executes whatever is in this file. **This matters in Phase 2.**
