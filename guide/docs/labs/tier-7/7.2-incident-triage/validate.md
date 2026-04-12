# Lab 7.2: Supply Chain Incident Triage

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

**Goal:** Assign severity, document blast radius, and take containment actions.

## Step 1: Classify severity

Use the severity classification reference below to score your incident. Fill in the "Finding" and "Score" columns based on what you discovered in Investigate.

**Severity classification reference:**

| Score | Functional Impact | Information Impact | Recoverability |
|-------|------------------|--------------------|---------------|
| High | Production system compromised | Credentials/PII exfiltrated | Attacker may have already used stolen access |
| Medium | Non-prod system compromised | Internal data exposed | Recoverable with effort |
| Low | No system compromise | No sensitive data exposed | Easily recoverable |

Fill in your assessment:

| Factor | Finding | Score |
|--------|---------|-------|
| **Functional impact** | [What did you find about production deployments?] | ? |
| **Information impact** | [What secrets were exfiltrated?] | ? |
| **Recoverability** | [Can this be undone? Has the attacker already acted?] | ? |
| **Affected users** | [Which services handle customer data?] | ? |

**Severity Classification:** SEV-? (assign based on your findings)

## Step 2: Document the blast radius

Fill in this template using data from Investigate:

```
BLAST RADIUS ASSESSMENT
=======================
Compromise window:    [start time] to present ([duration])
Affected CI runners:  [count] ([list])
Affected pipelines:   [count] ([list])
Affected artifacts:   [count] container images
Deployed to prod:     [count] ([which?])
Exfiltrated secrets:  [count] credentials across [count] pipelines
Attacker C2:          [domain from setup.py] (IP: [from DNS/logs])
```

## Step 3: Immediate containment actions

Based on your blast radius assessment, fill in the containment actions. Think about three priority levels:

- **P0 (immediate):** Actions that stop active data loss (secret rotation, access revocation)
- **P1 (urgent):** Actions that limit blast radius (quarantine, rollback, network blocks)
- **P2 (soon):** Actions that prevent recurrence (config fixes, forensic investigation)

| Priority | Action | Owner |
|----------|--------|-------|
| P0 | [What secrets need rotating first?] | ? |
| P0 | ? | ? |
| P1 | ? | ? |
| P1 | ? | ? |
| P2 | ? | ? |

<details>
<summary>Solution</summary>

**Containment actions (expected):**

| Priority | Action | Owner |
|----------|--------|-------|
| P0 | Rotate ALL exposed AWS keys immediately | Platform team |
| P0 | Rotate Stripe secret key | Payment team |
| P0 | Revoke GH_TOKEN and issue new token with reduced scope | Security team |
| P0 | Rotate JWT signing key (will invalidate all sessions) | Auth team |
| P1 | Quarantine affected container images in registry | Platform team |
| P1 | Roll back api-service to last known-good version (v2.14.2) | SRE team |
| P1 | Block attacker C2 at firewall | Network team |
| P1 | Remove `internal-utils@99.0.0` from pip cache on all runners | Platform team |
| P2 | Fix pip configuration: replace `--extra-index-url` with `--index-url` | DevOps team |
| P2 | Scan AWS CloudTrail for unauthorized API calls using the stolen keys | Security team |

</details>

## Step 4: Check for secondary compromise

The attacker had the GH_TOKEN for 3+ hours. Check for repository modifications:

```yaml
index=github sourcetype=github:audit
  actor!="dependabot[bot]" actor!="renovate[bot]"
  earliest="2026-04-01T11:43:00"
  action IN ("git.push", "repo.create", "team.add_member", "org.invite_member")
| table _time, actor, action, repo, details
```
