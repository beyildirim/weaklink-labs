# Hint 2: Building the Comparison Matrix

## Matrix Structure

Your matrix should have tools as rows and capabilities as columns:

| Tool | Known CVEs | Dep Confusion | Typosquatting | Manifest Confusion | Phantom Deps | License | Cost | CI Integration |
|------|-----------|--------------|--------------|-------------------|-------------|---------|------|---------------|
| pip-audit | ? | ? | ? | ? | ? | ? | Free | ? |
| Trivy | ? | ? | ? | ? | ? | ? | Free | ? |
| Grype | ? | ? | ? | ? | ? | ? | Free | ? |
| Snyk | ? | ? | ? | ? | ? | ? | Freemium | ? |
| Socket | ? | ? | ? | ? | ? | ? | Freemium | ? |
| Dependabot | ? | ? | ? | ? | ? | ? | Free | ? |
| Scorecard | ? | ? | ? | ? | ? | ? | Free | ? |
| npm audit | ? | ? | ? | ? | ? | ? | Free | ? |
| GUAC | ? | ? | ? | ? | ? | ? | Free | ? |
| deps.dev | ? | ? | ? | ? | ? | ? | Free | ? |

Use these ratings:
- **Full:** detects the attack type reliably
- **Partial:** detects some variants or requires configuration
- **None:** does not detect this attack type
- **N/A:** not applicable to this tool's scope

## What You'll Likely Find

Most tools cluster around **known CVE detection**. Very few detect:
- Dependency confusion (behavioral analysis needed)
- Typosquatting (name similarity analysis needed)
- Manifest confusion (requires comparing published metadata vs. repository source)

This gap is the key finding for your recommendation.

## Recommendation Tips

Don't recommend one tool. Recommend a **stack**:
- Layer 1: CVE scanning (pick the best free option)
- Layer 2: Behavioral analysis (for supply chain-specific attacks)
- Layer 3: Policy/posture (Scorecard for open-source dependencies)
