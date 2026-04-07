# Supply Chain Security Tool Comparison Matrix

## Instructions

Fill in each cell after running the tool against the WeakLink lab workstation. Use these ratings:

- **Full:** reliably detects this attack type
- **Partial:** detects some variants or requires specific configuration
- **None:** does not detect this attack type
- **N/A:** outside this tool's scope

## Matrix

| Tool | Known CVEs | Dependency Confusion | Typosquatting | Lockfile Injection | Manifest Confusion | Phantom Dependencies | License Compliance | SBOM Generation | CI/CD Integration | Cost |
|------|-----------|---------------------|--------------|-------------------|-------------------|---------------------|-------------------|----------------|-------------------|------|
| **pip-audit** | | | | | | | | | | Free |
| **npm audit** | | | | | | | | | | Free |
| **Grype** | | | | | | | | | | Free |
| **Trivy** | | | | | | | | | | Free |
| **Snyk** | | | | | | | | | | Freemium |
| **Socket** | | | | | | | | | | Freemium |
| **Dependabot** | | | | | | | | | | Free (GitHub) |
| **OpenSSF Scorecard** | | | | | | | | | | Free |
| **GUAC** | | | | | | | | | | Free |
| **deps.dev** | | | | | | | | | | Free |

## Tool Command Reference

```bash
# pip-audit
pip-audit -r requirements.txt --output json

# npm audit
npm audit --json

# Grype
grype dir:./target-project --output json

# Trivy
trivy fs ./target-project --format json

# Snyk (requires auth)
snyk test --json

# Socket (requires auth)
# Use GitHub App or socket-cli

# OpenSSF Scorecard
scorecard --repo=github.com/owner/repo --format json

# GUAC
# Ingest SBOM, then query via GraphQL

# deps.dev API
curl "https://api.deps.dev/v3/systems/pypi/packages/PACKAGE_NAME"
```

## Evaluation Criteria (beyond detection)

| Criteria | Weight | Notes |
|----------|--------|-------|
| Detection accuracy | High | True positive rate across attack types |
| False positive rate | High | Low FP = less analyst fatigue |
| Speed / Performance | Medium | Time to scan a medium project |
| CI integration ease | Medium | GitHub Actions, GitLab CI, Jenkins |
| Reporting quality | Low | Human-readable output, SARIF support |
| Maintenance burden | Medium | Requires API keys? Self-hosted? DB updates? |
| Community / Support | Low | Documentation quality, issue response time |

## Summary Findings

### Best for known CVE detection:
<!-- Your finding here -->

### Best for supply chain-specific attacks:
<!-- Your finding here -->

### Best overall value (free tier):
<!-- Your finding here -->

### Recommended stack:
<!-- Your recommended layered approach here -->

## Recommendation

<!-- 
Write a 1-page recommendation for your organization:
1. Which tools to adopt and in what order
2. What each tool covers and what gaps remain
3. Estimated effort to integrate into existing CI/CD
4. Cost analysis (free vs. paid tier trade-offs)
-->
