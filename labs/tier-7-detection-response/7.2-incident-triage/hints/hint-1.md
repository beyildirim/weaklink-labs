# Hint 1: Starting the Investigation

You received the alert: **"internal-utils@99.0.0 installed in CI pipeline 3 hours ago."**

Your first 15 minutes should focus on **scoping**, not remediation. You need to know how big the problem is before you act.

## Step 1: Identify affected pipelines

Look at `src/logs/ci-pipeline-logs.json`. Search for every CI run that installed `internal-utils` in the last 24 hours. Key fields:

- `pipeline_id` -- which pipeline ran
- `timestamp` -- when it ran
- `package_version` -- what version was installed
- `runner_id` -- which runner executed it

## Step 2: Identify exposed secrets

Each CI pipeline has access to environment variables. Check `src/logs/ci-environment-audit.json` for:

- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`
- `NPM_TOKEN`
- `DOCKER_PASSWORD`
- `GITHUB_TOKEN`
- Any `*_API_KEY` variables

Every secret that was **in memory** during a compromised build must be considered exposed.

## Step 3: Determine what the package did

Look at `src/malicious-package/setup.py`. What does it execute on install? Does it exfiltrate data? Drop a backdoor? Modify other files?

This determines the severity. Data exfiltration = Critical. Code modification only = High.
