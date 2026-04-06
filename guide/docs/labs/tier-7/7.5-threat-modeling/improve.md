# Lab 7.5: Threat Modeling for Software Supply Chains

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

**Goal:** Rank threats by risk and map to controls from earlier labs.

## Risk ranking (top 5)

| Rank | Threat | Boundary | Existing Control |
|:----:|--------|----------|-----------------|
| 1 | Dependency confusion | TB-3 | Version pinning (partial) |
| 2 | Secret exfiltration via malicious package | TB-4 | None |
| 3 | Over-privileged CI secrets | TB-4 | None |
| 4 | Typosquatting | TB-3/TB-5 | None |
| 5 | Tampered lockfile | TB-1 | PR reviews (partial) |

## Remediation roadmap

| Timeline | Action | Addresses | Effort |
|----------|--------|-----------|--------|
| **Week 1** | Fix pip config: `--index-url` only | Dependency confusion | Low |
| **Week 1** | Scope CI secrets per workflow | Over-privileged secrets | Medium |
| **Week 2** | Add `--require-hashes` to all requirements files | Dep confusion, typosquatting | Medium |
| **Week 2** | Add lockfile diff check to PR CI | Lockfile injection | Low |
| **Month 1** | Adopt Socket for behavioral analysis | Typosquatting, malicious packages | Medium |
| **Month 1** | Implement image signing with cosign | Tag mutability, missing provenance | Medium |
| **Month 2** | Deploy SLSA Level 2 build provenance | Missing provenance | High |
| **Quarter 2** | Enforce commit signing | Unsigned commits | Medium |
| **Quarter 2** | Migrate CI to OIDC credentials | Secret exfiltration risk | High |

## Final verification

```bash
weaklink verify 7.5
```

## What You Learned

- STRIDE systematically identifies threats at trust boundaries. Applied to supply chains, it reveals 24+ distinct threats across 7 boundaries.
- Tampering and Spoofing dominate supply chain threats, matching real-world attack patterns.
- Prioritization via Risk = Likelihood x Impact prevents remediation paralysis.

## Further Reading

- [Microsoft STRIDE Threat Modeling](https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats)
- [OWASP Threat Modeling](https://owasp.org/www-community/Threat_Modeling)
- [SLSA: Supply-chain Levels for Software Artifacts](https://slsa.dev/)
