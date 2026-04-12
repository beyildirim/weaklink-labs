# Lab 7.3: Incident Response Playbook

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

**Goal:** Create a step-by-step IR playbook for "compromised dependency detected in CI."

## Step 1: Define roles

| Role | Responsibility |
|------|---------------|
| **Incident Commander (IC)** | Coordinates response, makes decisions, communicates status |
| **SOC Analyst** | Detection, initial triage, log analysis |
| **Platform Engineer** | CI/CD systems, package registries, artifact stores |
| **Application Owner** | Knows what secrets the pipeline uses, application behavior |
| **Communications Lead** | Internal/external messaging, legal coordination |

## Step 2: Playbook. Preparation phase

```markdown
PREPARATION CHECKLIST
=====================

[ ] CI secrets inventory exists and is current (last updated: ____)
[ ] Triage workflow practiced and ready to use
[ ] Package manager hardening
    - --index-url (not --extra-index-url) in all pip configs
    - npm registry locked to corporate registry
    - --require-hashes enabled where possible
[ ] Artifact integrity
    - Container images signed with cosign
    - Build provenance generated (SLSA Level 2+)
[ ] Communication templates drafted
[ ] Tabletop exercise completed within last 6 months
```

## Step 3: Playbook. Detection and Analysis phase

```markdown
DETECTION & ANALYSIS
====================

TRIGGER: Alert from detection rule OR analyst observation OR user report

STEP 1: Validate the alert (5 min SLA)
  - Pull raw log event. Confirm package name, version, source registry, CI runner.
  - Check FP allow-list. If confirmed false positive: close, update allow-list.

STEP 2: Classify severity (5 min SLA)
  SEV-1: Malicious package installed + secrets exfiltrated OR compromised artifact in prod
  SEV-2: Malicious package installed, no confirmed exfil OR compromised artifact in staging only
  SEV-3: Suspicious package detected, not yet installed

STEP 3: Scope the blast radius (15 min SLA)
  - Proxy logs: which CI runners downloaded the package?
  - CI logs: which pipelines ran during the compromise window?
  - Secret manager: what secrets were accessible?
  - Artifact registry: what artifacts were built?
  - Deployment logs: were compromised artifacts deployed?

STEP 4: Analyze the malicious package (15 min SLA)
  - Download without execution: pip download --no-deps --no-build-isolation
  - Document: What does it do? Exfil? Backdoor? Persistence?
  - Identify C2 infrastructure

STEP 5: Open incident channel
  - Create Slack channel: #incident-YYYY-NNNN
  - Page IC, Platform Engineer, Application Owner(s)
```

## Step 4: Playbook. Containment phase

```markdown
CONTAINMENT (execute in parallel)
=================================

IMMEDIATE (0-15 min):
  [ ] Block attacker C2 domain/IP at firewall and DNS
  [ ] Remove malicious package from pip/npm cache on all CI runners
  [ ] Halt all deployments (freeze the pipeline)
  [ ] If compromised artifact in production: initiate rollback

SHORT-TERM (15-60 min):
  [ ] Rotate ALL secrets accessible to affected pipelines
  [ ] Quarantine compromised artifacts in registry (do not delete -- forensics)
  [ ] Isolate affected CI runners for forensic analysis
  [ ] Revoke any tokens/sessions that may have been forged with stolen keys
```

## Step 5: Playbook. Eradication phase

```markdown
ERADICATION
===========

ROOT CAUSE REMEDIATION:
  [ ] Fix package manager configuration
  [ ] Add --require-hashes to all requirements files
  [ ] Claim internal package names on public registries
  [ ] Rebuild affected CI runners from clean images

ARTIFACT REMEDIATION:
  [ ] Rebuild ALL artifacts from the compromise window using clean CI
  [ ] Verify rebuilt artifacts with diffoscope or similar
  [ ] Re-sign rebuilt artifacts

VERIFICATION:
  [ ] Re-run detection rules against post-fix CI logs
  [ ] Verify all rotated secrets are working
  [ ] Confirm rollback is stable
```

## Step 6: Playbook. Recovery and Lessons Learned

```markdown
RECOVERY
========
  [ ] Resume deployments with clean artifacts
  [ ] Monitor 24-48 hours for signs of persistent access
  [ ] Audit cloud provider logs for unauthorized API calls during compromise window
  [ ] If customer data exposure confirmed: engage legal

LESSONS LEARNED (schedule within 5 business days)
==================================================
  AGENDA:
  1. Timeline review
  2. What worked well
  3. What did not work / gaps identified
  4. Detection improvements
  5. Prevention improvements
  6. Action items with owners and due dates
```

---

<details open>
<summary>Checkpoint</summary>

You should have a complete playbook covering Preparation, Detection, Containment, Eradication, Recovery, and Lessons Learned. Walk through the Lab 7.2 scenario mentally and verify every step is covered.

</details>
