# Hint 2: Applying STRIDE to Supply Chain Boundaries

## STRIDE Quick Reference

| Letter | Threat | Question |
|--------|--------|----------|
| **S** | Spoofing | Can an attacker impersonate a legitimate entity? |
| **T** | Tampering | Can an attacker modify data in transit or at rest? |
| **R** | Repudiation | Can an attacker deny their actions? |
| **I** | Information Disclosure | Can an attacker read data they shouldn't? |
| **D** | Denial of Service | Can an attacker prevent legitimate use? |
| **E** | Elevation of Privilege | Can an attacker gain higher access than intended? |

## Example: STRIDE at "CI pulls dependencies from package registry"

| STRIDE | Threat | Example Attack | Likelihood | Impact |
|--------|--------|---------------|------------|--------|
| **S** | Attacker publishes package with same name as internal package | Dependency confusion (Lab 1.2) | High | Critical |
| **T** | Attacker modifies package after publication | Registry compromise, lockfile injection (Lab 1.4) | Medium | Critical |
| **R** | Package publisher denies publishing malicious version | No provenance/signing on packages | High | Medium |
| **I** | Build secrets leaked via malicious package install script | setup.py exfiltration | High | Critical |
| **D** | Attacker publishes broken package that fails builds | Namespace squatting | Medium | Low |
| **E** | Malicious package gains CI runner privileges | setup.py runs as build user with secret access | High | Critical |

## Prioritization Framework

Use a simple likelihood x impact matrix:

```
              Impact
              Low    Medium   High    Critical
Likelihood
High          Med    High     Crit    Crit
Medium        Low    Med      High    Crit
Low           Low    Low      Med     High
```

Map each threat to this matrix, then sort by risk score (Critical > High > Medium > Low).

For gap analysis: check which threats are **already mitigated** by controls you built in Tiers 1-6 (version pinning, lockfile verification, signing, registry configuration). The unmitigated threats are your gaps.
