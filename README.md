# WeakLink Labs

**Learn supply chain security by breaking and fixing real pipelines.**

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/beyildirim/weaklink-labs?quickstart=1)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Labs: 62](https://img.shields.io/badge/Labs-62-orange.svg)](#what-youll-learn)

## The Problem

Supply chain attacks have increased 742% since 2019. Most security training covers the theory but never lets you touch a poisoned package, hijack a CI pipeline, or forge an attestation. WeakLink Labs gives you 62 hands-on labs where you exploit real attack techniques in a safe, isolated environment, then learn exactly how to stop them.

## Quick Start

### Docker Compose (recommended)

```bash
git clone https://github.com/beyildirim/weaklink-labs.git
cd weaklink-labs
make compose-up
```

Open **http://localhost:8000** in your browser. Done.

### Kubernetes (full experience)

```bash
git clone https://github.com/beyildirim/weaklink-labs.git
cd weaklink-labs
./start.sh
```

Requires Docker, minikube, kubectl, and Helm. See [Prerequisites](#prerequisites).

### GitHub Codespaces (zero install)

Click the **Open in GitHub Codespaces** badge above. Everything is pre-installed.

## What You'll Learn

| Tier | Topic | Labs |
|------|-------|:----:|
| **0** | **Foundations** — Version control, package managers, containers, CI/CD | 5 |
| **1** | **Package Security** — Dependency confusion, typosquatting, lockfile injection | 6 |
| **2** | **Build & CI/CD** — Pipeline poisoning, secret exfiltration, runner attacks | 8 |
| **3** | **Container Security** — Image tampering, registry confusion, layer attacks | 6 |
| **4** | **SBOM & Signing** — SBOMs, signing, attestations, and how to bypass them | 7 |
| **5** | **IaC Supply Chain** — Helm, Terraform, Ansible, admission controllers | 5 |
| **6** | **Case Studies & Frontier Attacks** — xz-utils, SolarWinds, Log4Shell, AI/ML supply chain | 10 |
| **7** | **Detection & Response** — SIEM rules, incident triage, IR playbooks, threat modeling | 5 |
| **8** | **Policy & Program Building** — SLSA, SSDF, SCVS, EO 14028, building a program | 6 |
| **9** | **Cloud Supply Chain** — Marketplace poisoning, serverless, cloud CI/CD, IAM chains | 4 |

## Who Is This For?

| You are a... | Start here | Focus on |
|--------------|-----------|----------|
| **SOC Analyst** | Tier 0 | Detect phases and Tier 7 (Detection & Response) |
| **Security Engineer** | Take the [placement test](#cli-reference), likely Tier 1 | Full path through Tiers 1-6 |
| **DevSecOps** | Tier 2 | CI integration sections, Tiers 4-5 |
| **DevOps Engineer** | Tier 0 | Defend phases, Tiers 2-3 and 5 |
| **Team Lead / Manager** | Tier 0, then Tier 8 | Tier 8 (Policy & Program Building) |

## How Every Lab Works

Each lab follows four phases:

**1. Understand** — See the system working normally. In Lab 0.2, you install a package from a private registry and inspect how dependency resolution works. In Lab 3.1, you pull apart container image layers to see what is actually inside.

**2. Break** — Exploit a real vulnerability. In Lab 1.2, you publish a malicious package to a public registry and watch the build system pull it instead of the private one. In Lab 2.4, you inject a step into a CI pipeline that exfiltrates secrets to an external endpoint.

**3. Defend** — Apply the fix, re-run the attack, watch it fail. In Lab 1.2, you configure scoped registries and pin hashes. In Lab 4.3, you sign an artifact with Cosign and set up verification that rejects unsigned images.

**4. Detect** — Write detection logic and map to MITRE ATT&CK. In Lab 1.3, you identify typosquatting indicators in package metadata. In Lab 2.2, you trace pipeline modification events to detect poisoned pipelines before they execute.

## Highlights

- **6 real-world case studies** dissecting SolarWinds, Log4Shell, xz-utils, Codecov, event-stream, and Equifax
- **Detection content with MITRE ATT&CK mapping** in every lab
- **Placement test** to skip what you already know
- **Full isolation** with private registries (PyPI, npm, OCI), Gitea, and a pre-configured workstation

## CLI Reference

Inside the workstation, the `weaklink` CLI manages your entire workflow:

```bash
weaklink start <lab-id>    # Start a lab (e.g., weaklink start 1.2)
weaklink verify <lab-id>   # Check if you completed the lab
weaklink hint <lab-id>     # Get a progressive hint
weaklink info <lab-id>     # Show lab metadata (time, difficulty, prerequisites)
weaklink path              # Show the learning roadmap and your progress
weaklink assess            # Take the placement test
weaklink reset <lab-id>    # Reset a lab's completion status
weaklink report            # Progress report (supports --json, --csv, --team)
# weaklink achieve         # (planned) View achievements and generate badges
```

## Prerequisites

**Docker Compose path:** Only Docker is required.

**Kubernetes path:**

| Tool | Minimum version | Install |
|------|----------------|---------|
| [Docker](https://docs.docker.com/get-docker/) | 20.10+ | `brew install --cask docker` |
| [minikube](https://minikube.sigs.k8s.io/) | 1.30+ | `brew install minikube` |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | 1.27+ | `brew install kubectl` |
| [Helm](https://helm.sh/) | 3.12+ | `brew install helm` |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the lab template and guidelines.

## License

[MIT](LICENSE)
