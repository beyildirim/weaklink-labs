# Lab 7.3: Incident Response Playbook

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../investigate/" class="phase-step done">Investigate</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Validate</span>
  <span class="phase-arrow">›</span>
  <a href="../improve/" class="phase-step upcoming">Improve</a>
</div>

**Goal:** Apply the playbook to the dependency confusion incident from [Lab 7.2](../7.2-incident-triage/).

## Step 1: Trace the incident through the playbook

| Playbook Step | Lab 7.2 Action | Covered? |
|---------------|----------------|----------|
| Validate alert | Confirmed `internal-utils@99.0.0` from public PyPI | Yes |
| Classify severity | SEV-1: secrets exfiltrated + prod deployment | Yes |
| Scope blast radius | 3 runners, 3 pipelines, 8 secrets, 1 prod deploy | Yes |
| Analyze package | setup.py exfiltrates env vars to attacker C2 | Yes |
| Block C2 | Block `collect.attacker.com` at firewall | Yes |
| Rotate secrets | All 8 credentials rotated | Yes |
| Quarantine artifacts | 3 container images quarantined | Yes |
| Rollback production | api-service rolled back to v2.14.2 | Yes |
| Fix root cause | pip config changed to --index-url | Yes |
| Rebuild artifacts | Clean rebuild from verified source | Yes |

## Step 2: Identify gaps

| Gap | Improvement |
|-----|-------------|
| No pre-built forensic image | Pre-stage a sandboxed analysis VM for package forensics |
| Secret inventory was stale | Automate CI secrets inventory with monthly refresh |
| No deployment freeze automation | Create a "kill switch" that freezes all deployments via API |
| Rollback required manual approval | Pre-approve emergency rollbacks for SEV-1 incidents |
