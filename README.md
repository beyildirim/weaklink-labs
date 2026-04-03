# WeakLink Labs

**Hands-on labs that teach security teams how software supply chains work — and how they break.**

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/beyildirim/weaklink-labs?quickstart=1)

---

## The Problem

Security teams are asked to defend software supply chains they don't understand. SOC analysts receive alerts about dependency confusion, pipeline poisoning, and SBOM gaps — but many have never run `pip install` or seen a CI pipeline execute.

**This project fixes that.** Each lab teaches you how a system works, then how attackers exploit it, then how to defend it.

## Who This Is For

- **SOC analysts** who triage supply chain alerts but don't understand the underlying systems
- **Security engineers** who need hands-on experience with supply chain attack techniques
- **DevOps engineers** who want to understand the security implications of their tooling
- **GRC/compliance teams** who need to assess supply chain risk with real understanding

## How It Works

Every lab follows the same three-phase structure:

1. **UNDERSTAND** — See the system working normally. Explore it. Know what it does.
2. **BREAK** — Exploit a real vulnerability. See the impact firsthand.
3. **DEFEND** — Apply the fix. Re-run the attack. It fails. You know why.

## Quick Start

### Option 1: GitHub Codespaces (recommended — nothing to install)

Click the badge above, or:

```bash
# From the GitHub repo page, click Code → Codespaces → Create codespace
```

### Option 2: Run locally

```bash
git clone https://github.com/beyildirim/weaklink-labs.git
cd weaklink-labs
# Requires: Docker, Docker Compose, bash

# Start a lab
./cli/weaklink start 0.1

# See the roadmap
./cli/weaklink path
```

## Learning Path

Labs are organized in tiers that build on each other:

| Tier | Topic | Labs | Prerequisites |
|------|-------|------|---------------|
| **0** | **Foundations** — Version control, package managers, containers, CI/CD | 5 | None |
| **1** | **Package Security** — Dependency confusion, typosquatting, lockfile attacks | 6 | Tier 0 |
| **2** | **Build & CI/CD** — Pipeline poisoning, secret exfiltration, runner attacks | 8 | Tier 1 |
| **3** | **Container Security** — Image tampering, registry confusion, layer attacks | 6 | Tier 0 |
| **4** | **Artifact Integrity** — SBOMs, signing, attestations, and how to bypass them | 7 | Tier 2 |
| **5** | **IaC Supply Chain** — Helm, Terraform, and infrastructure-as-code attacks | 5 | Tier 3 |
| **6** | **Advanced & Emerging** — AI/ML supply chain, case studies, chained attacks | 8 | Tier 4 |
| **7** | **Detection & Response** — Building detection, incident response, threat modeling | 5 | Tier 5 |
| **8** | **Organizational** — SLSA, SSDF, compliance, building a security program | 5 | Tier 7 |

Use `weaklink path` to see your progress and which labs are unlocked.

## CLI Reference

```bash
weaklink path              # Show the learning roadmap and your progress
weaklink start <lab-id>    # Start a lab (e.g., weaklink start 1.2)
weaklink stop              # Stop the current lab
weaklink verify <lab-id>   # Check if you completed the lab
weaklink hint <lab-id>     # Get a progressive hint (won't spoil everything)
weaklink reset <lab-id>    # Reset a lab to try again
weaklink info <lab-id>     # Show lab details and phases
weaklink status            # Show what's currently running
```

## Contributing

We welcome new labs! See [CONTRIBUTING.md](CONTRIBUTING.md) for the lab template and guidelines.

## License

MIT

## Acknowledgments

Inspired by [Kubernetes Goat](https://github.com/madhuakula/kubernetes-goat), the [OWASP Top 10 CI/CD Security Risks](https://owasp.org/www-project-top-10-ci-cd-security-risks/), and every SOC analyst who asked "but what does that alert actually mean?"
