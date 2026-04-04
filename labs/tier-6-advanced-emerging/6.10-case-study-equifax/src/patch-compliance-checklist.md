# Patch Compliance Checklist Template

This checklist addresses the systemic failures that led to the Equifax breach.
The patch for CVE-2017-5638 was available for **two months** before exploitation began.
The internal scanner identified it. Nobody applied it.

## Patching SLAs by Severity

| Severity | CVSS Range | SLA | Escalation |
|----------|-----------|-----|------------|
| Critical | 9.0 - 10.0 | 48 hours | CISO notified at 24h if unpatched |
| High | 7.0 - 8.9 | 7 days | Manager notified at 5d if unpatched |
| Medium | 4.0 - 6.9 | 30 days | Tracked in sprint backlog |
| Low | 0.1 - 3.9 | 90 days | Tracked in quarterly maintenance |

## Remediation Workflow

### 1. Discovery
- [ ] Vulnerability scanner identifies CVE in deployed component
- [ ] Asset inventory maps affected component to owning team
- [ ] Ticket auto-created and assigned to component owner
- [ ] Severity and SLA clock starts

### 2. Assessment
- [ ] Component owner confirms the vulnerability applies (not false positive)
- [ ] Impact assessment: is the vulnerable code path reachable?
- [ ] Patch availability confirmed (vendor patch, workaround, or mitigation)
- [ ] Downtime/change window requirements identified

### 3. Remediation
- [ ] Patch applied in staging environment
- [ ] Regression testing completed
- [ ] Change request approved
- [ ] Patch deployed to production
- [ ] Deployment verified (version check, vulnerability rescan)

### 4. Verification
- [ ] Vulnerability scanner confirms remediation
- [ ] Ticket closed with evidence of patch application
- [ ] SLA compliance recorded

### 5. Escalation (SLA Breach)
- [ ] At 50% of SLA: automated reminder to component owner
- [ ] At 75% of SLA: manager notified
- [ ] At 100% of SLA: CISO/VP Engineering notified
- [ ] At 150% of SLA: risk acceptance required (signed by VP+)
- [ ] Compensating controls applied if patch cannot be deployed

## What Failed at Equifax

1. **No ownership mapping**: The scanner found CVE-2017-5638, but there was
   no clear owner for the affected Struts installation
2. **No SLA enforcement**: There was no escalation when the patch was not
   applied within a defined timeframe
3. **No verification loop**: Nobody confirmed the patch was actually deployed
4. **Expired SSL certificate on inspection tool**: Equifax's network
   monitoring tool had an expired SSL certificate, so encrypted traffic
   from the attackers was not inspected for 19 months
5. **No compensating controls**: No WAF rule was deployed to block the
   known exploit pattern while waiting for the patch
