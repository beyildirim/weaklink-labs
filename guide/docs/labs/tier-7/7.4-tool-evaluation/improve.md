# Lab 7.4: Supply Chain Security Tool Evaluation

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

**Goal:** Produce a tiered adoption plan.

**Immediate (zero cost):** pip-audit/npm-audit in every CI pipeline, Dependabot on all repos, Scorecard weekly.

**Short-term (Month 1):** Trivy for container/secret/misconfig scanning. Socket for behavioral analysis.

**Medium-term (Quarter 1):** GUAC for dependency graph queries at scale. Scorecard + deps.dev dashboard.

## What tools cannot replace

1. **Hardened CI/CD configuration**. `--index-url` not `--extra-index-url`, pinned hashes, locked registries.
2. **SIEM detection rules**. the rules from [Lab 7.1](../7.1-detection-rules/) catch what no scanner can.
3. **Incident response playbooks**. [Lab 7.3](../7.3-ir-playbook/) is your response when tools fail.

## Final verification

```bash
weaklink verify 7.4
```

## What You Learned

- Vulnerability scanners only catch known CVEs. They miss every novel supply chain attack.
- Behavioral analysis (Socket) fills the biggest gap by detecting malicious behavior in packages not in vulnerability databases.
- Tools are not a substitute for hardened configuration. Fixing `--extra-index-url` eliminates dependency confusion entirely, which no scanning tool can claim.

## Further Reading

- [OpenSSF Scorecard](https://securityscorecards.dev/)
- [GUAC: Graph for Understanding Artifact Composition](https://guac.sh/)
- [Socket.dev](https://socket.dev/)
