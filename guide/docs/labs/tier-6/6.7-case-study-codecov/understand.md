# Lab 6.7: Case Study: Codecov Bash Uploader

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../analyze/" class="phase-step upcoming">Analyze</a>
  <span class="phase-arrow">›</span>
  <a href="../lessons/" class="phase-step upcoming">Lessons</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## curl | bash in CI/CD Pipelines

**Goal:** Understand why piping external scripts into bash is a supply chain risk.

### The timeline

| Date | Event |
|------|-------|
| 2021-01-31 | Attackers modify Codecov's Bash Uploader on codecov.io |
| 2021-01-31 to 2021-04-01 | Compromised script runs in thousands of CI/CD pipelines (~2 months) |
| 2021-04-01 | Codecov discovers and discloses the breach |
| 2021-04-15 | Hashicorp, Twitch, and others confirm they were affected |

### How the uploader was used

```bash
cat /app/ci-pipeline/workflow-before.yml
```

The standard integration: `curl -s https://codecov.io/bash | bash`. Downloads and executes immediately with full access to the CI environment.

### Download a script and verify its hash

```bash
curl -fsSL http://exfil-server:8080/uploader.sh -o /tmp/uploader.sh
sha256sum /tmp/uploader.sh
cat /app/uploader/known-good-hash.txt
```

Compare the hash. If they differ, the script was modified in transit or at the source. This is exactly what happened to Codecov's uploader: the hash changed, but nobody was checking.

### What CI environments contain

```bash
cat /app/ci-pipeline/env-example.txt
```

`GITHUB_TOKEN`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `DOCKER_PASSWORD`, `NPM_TOKEN`, `DATABASE_URL`. The Bash Uploader had access to all of them.
