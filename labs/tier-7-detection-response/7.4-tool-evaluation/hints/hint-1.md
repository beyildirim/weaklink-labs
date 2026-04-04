# Hint 1: Running the Tools

## Quick Start for Each Tool

### OpenSSF Scorecard
```bash
# Checks a GitHub repo's security posture
scorecard --repo=github.com/owner/repo
# Or use the REST API: https://api.securityscorecards.dev
```
Focus areas: branch protection, dependency update tooling, signed releases, CI tests.

### GUAC (Graph for Understanding Artifact Composition)
```bash
# GUAC ingests SBOMs, SLSA attestations, and vulnerability data into a graph DB
# Best tested via the demo: https://docs.guac.sh/getting-started/
```
Focus: relationship queries between packages, vulnerabilities, and build provenance.

### deps.dev
```bash
# Google's dependency insight API
curl "https://api.deps.dev/v3/systems/pypi/packages/requests"
```
Focus: transitive dependency info, known advisories, OpenSSF Scorecard data.

### pip-audit
```bash
pip-audit -r requirements.txt
# Uses the OSV database
```

### npm audit
```bash
npm audit --json
```

### Grype
```bash
grype dir:. --output json
```

### Trivy
```bash
trivy fs . --format json
```

### Socket
```bash
# Socket analyzes package behavior (network calls, filesystem access, shell execution)
# Sign up at https://socket.dev, use the GitHub App or CLI
```

**Key insight**: Most scanners only find **known CVEs**. Only Socket and manual analysis catch behavioral anomalies like dependency confusion and typosquatting.
