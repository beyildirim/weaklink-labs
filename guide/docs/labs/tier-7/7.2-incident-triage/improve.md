# Lab 7.2: Supply Chain Incident Triage

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../investigate/" class="phase-step done">Investigate</a>
  <span class="phase-arrow">›</span>
  <a href="../validate/" class="phase-step done">Validate</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Improve</span>
</div>

**Goal:** Produce the incident summary for management and identify detection improvements.

## Incident summary

```markdown
INCIDENT SUMMARY: Supply Chain Compromise via Dependency Confusion
==================================================================

Incident ID:    INC-2026-0042
Severity:       SEV-1 (Critical)
Status:         Active, containment in progress
Commander:      [Your name]
Detection time: 2026-04-01 14:47 UTC
Compromise start: 2026-04-01 11:43 UTC (estimated)
Time to detect: 3 hours 4 minutes

SUMMARY:
A malicious package "internal-utils@99.0.0" was published to public PyPI,
exploiting dependency confusion in our CI/CD pip configuration. Installed by
3 pipelines over 3 hours. Malicious setup.py exfiltrated environment variables
(AWS keys, Stripe API key, GitHub token, JWT signing key) to attacker C2.
One compromised artifact deployed to production.

ROOT CAUSE:
CI pip configuration used --extra-index-url (checks both private and public
PyPI) instead of --index-url (private only).

IMPACT:
- 8 credentials exfiltrated to attacker infrastructure
- 1 compromised container deployed to production for ~3 hours
- Customer data exposure possible via stolen Stripe and AWS credentials

CONTAINMENT ACTIONS:
- All 8 credentials rotated
- Compromised container rolled back
- Attacker C2 blocked at firewall
- pip configuration fixed across all CI runners

NEXT STEPS:
- CloudTrail and Stripe audit for unauthorized access
- Full forensic analysis of CI runners
- Post-incident review scheduled for [date]
```

## Detection improvements

| Gap | Improvement |
|-----|------------|
| 3-hour detection lag | Reduce proxy log ingestion latency; add real-time alerting |
| No pre-install validation | Implement `--require-hashes` in all CI pipelines |
| Broad CI secrets exposure | Least-privilege: each pipeline only has the secrets it needs |
| No artifact provenance | Implement SLSA Level 2+ to prevent compromised artifact deployment |


## What You Learned

- Time-to-detect is the most critical metric. The 3-hour gap gave the attacker time to exfiltrate credentials and get a compromised artifact into production.
- Blast radius assessment requires querying multiple systems: proxy logs, CI/CD logs, deployment logs, and secret management systems.
- Containment is parallel, not sequential. Secret rotation, artifact quarantine, rollback, and network blocking happen simultaneously.

## Further Reading

- [NIST SP 800-61: Computer Security Incident Handling Guide](https://csrc.nist.gov/publications/detail/sp/800-61/rev-2/final)
- [CISA: Supply Chain Compromise Incident Response](https://www.cisa.gov/topics/supply-chain-security)
- [PagerDuty Incident Response Documentation](https://response.pagerduty.com/)
