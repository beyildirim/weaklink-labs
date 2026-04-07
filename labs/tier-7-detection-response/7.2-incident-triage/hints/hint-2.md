# Hint 2: Writing the Incident Summary

Your incident summary goes to the CISO and engineering leadership. It needs to be clear, factual, and actionable. No jargon they don't understand, no speculation.

## Structure

### 1. Executive Summary (2-3 sentences)
What happened, when, how bad.

Example: "A malicious package `internal-utils@99.0.0` was installed in 4 CI pipelines between 14:00-17:00 UTC via dependency confusion. The package exfiltrated environment variables including AWS credentials and NPM tokens to an attacker-controlled server."

### 2. Timeline
Use UTC timestamps. Be precise.

```
T-3h00m  14:02 UTC  Attacker publishes internal-utils@99.0.0 to public PyPI
T-2h55m  14:07 UTC  Pipeline frontend-deploy pulls internal-utils@99.0.0
T-2h48m  14:14 UTC  Pipeline api-build pulls internal-utils@99.0.0
...
T+0h00m  17:02 UTC  Detection rule fires: "internal package from public registry"
```

### 3. Blast Radius
- X pipelines affected
- Y secrets potentially exfiltrated
- Z artifacts produced from compromised builds (may contain backdoors)

### 4. Immediate Actions (Recommended)
1. **Quarantine:** disable affected pipelines NOW
2. **Rotate secrets:** every credential that was in a compromised runner's environment
3. **Block the package:** add `internal-utils` to the private registry to prevent future confusion
4. **Audit artifacts:** any container images or packages built during the compromise window must be rebuilt from clean runners

### 5. Severity Classification
Use your organization's scale. This is likely **SEV-1 / Critical** because it involves credential exfiltration with active attacker access.
