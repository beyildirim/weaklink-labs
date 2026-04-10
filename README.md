# WeakLink Labs

**Learn supply chain security by breaking and fixing real pipelines.**

[![Open in Codespaces](https://img.shields.io/badge/Open_in-Codespaces-blue?logo=github)](https://codespaces.new/beyildirim/weaklink-labs?quickstart=1)
[![Labs](https://img.shields.io/badge/Labs-50-orange)](guide/docs/getting-started.md)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![SLSA 3](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev)
[![Signed with Cosign](https://img.shields.io/badge/Signed_with-Cosign-blueviolet?logo=sigstore)](https://github.com/beyildirim/weaklink-labs/releases)
[![SBOM](https://img.shields.io/badge/SBOM-CycloneDX-lightgrey?logo=owasp)](https://github.com/beyildirim/weaklink-labs/releases)

## The Problem

Supply chain attacks have increased 742% since 2019. Most security training covers the theory but never lets you touch a poisoned package, hijack a CI pipeline, or forge an attestation. WeakLink Labs gives you 50 hands-on labs where you exploit real attack techniques in a safe, isolated environment, then learn exactly how to stop them.

## What WeakLink Labs Is

WeakLink Labs is a practical learning environment for people who do not yet have a clear mental model of software supply chain security. It is designed to make complex attacks understandable by showing how systems work, how they fail, and what reduces risk in the real world. The goal is not to turn every learner into a detection engineer or tool specialist. The goal is to build judgment across multiple roles, including SOC analysts, developers, DevOps, DevSecOps, and managers. The platform should feel simple to start, realistic to use, and focused on the security decisions that matter.

## Core Values

- **Teach judgment first.** Help learners understand what is happening, why it matters, and when human decisions are required.
- **Keep setup simple.** The main path should be easy to start and easy to explain.
- **Show multiple perspectives.** Supply chain security affects SOC, engineering, operations, and leadership, not just one team.
- **Prefer realism over mechanics.** Labs should feel like real systems, not like a game platform full of extra workflow.

## Quick Start

### Recommended Path

```bash
git clone https://github.com/beyildirim/weaklink-labs.git
cd weaklink-labs
make start
```

Open **http://localhost:8000** in your browser and use the built-in terminal. That is the main experience. Stop it with `make stop`.

### Docker-Only Alternative

```bash
git clone https://github.com/beyildirim/weaklink-labs.git
cd weaklink-labs
make compose-up
```

Open **http://localhost:8000** in your browser. Images are pulled from GHCR.

To pin a published release instead of `latest`, set `WEAKLINK_IMAGE_TAG=<release-tag>` before `make compose-up`.

### GitHub Codespaces (zero install)

Click the **Open in GitHub Codespaces** badge above. Everything is pre-installed.

For detailed setup, prerequisites, and host-side commands, see [guide/docs/getting-started.md](guide/docs/getting-started.md).

For a strict docs/content validation pass, run `make docs-check`.

## What You'll Learn

| Tier | Topic | Labs |
|------|-------|:----:|
| **0** | **Foundations** — Version control, package managers, containers, CI/CD | 5 |
| **1** | **Package Security** — Dependency confusion, typosquatting, lockfile injection | 6 |
| **2** | **Build & CI/CD** — Pipeline poisoning, secret exfiltration, runner attacks | 8 |
| **3** | **Container Security** — Image tampering, registry confusion, layer attacks | 6 |
| **4** | **SBOM & Signing** — SBOMs, signing, attestations, and how to bypass them | 7 |
| **5** | **IaC Supply Chain** — Helm, Terraform, Ansible, admission controllers | 5 |
| **6** | **Advanced Domains & Case Studies** — AI/ML, firmware, multi-vector attacks, major incidents | 10 |
| **7** | **Response & Threat Modeling** — Incident triage, IR playbooks, threat modeling | 3 |

**Recommended mainline:** Tiers `0-5`. They are the clearest continuation of the hands-on core product.

**Advanced branches:** Tiers `6-7`. They are useful, but they shift into case studies and response-oriented work instead of staying on the default browser-first attack path.

## Who Is This For?

| You are a... | Start here | Focus on |
|--------------|-----------|----------|
| **SOC Analyst** | Tier 0 | Core path first, then optional Tier 7 |
| **Security Engineer** | Take the [placement test](guide/docs/placement-test.md), likely Tier 1 | Mainline through Tiers 1-5, then optional Tiers 6-7 |
| **DevSecOps** | Tier 2 | CI integration sections, Tiers 4-5 |
| **DevOps Engineer** | Tier 0 | Defend phases, Tiers 2-3 and 5 |
| **Team Lead / Manager** | Tier 0 | Core path through Tier 5, then Tier 7.3 and 7.5 if you want response planning |

## How Every Lab Works

Most hands-on labs follow a simple teaching flow:

**1. Understand** — See the system working normally. In Lab 0.2, you install a package from a private registry and inspect how dependency resolution works. In Lab 3.1, you pull apart container image layers to see what is actually inside.

**2. Break** — Exploit a real vulnerability. In Lab 1.2, you publish a malicious package to a public registry and watch the build system pull it instead of the private one. In Lab 2.4, you inject a step into a CI pipeline that exfiltrates secrets to an external endpoint.

**3. Defend** — Apply the fix, re-run the attack, watch it fail. In Lab 1.2, you configure scoped registries and pin hashes. In Lab 4.3, you sign an artifact with Cosign and set up verification that rejects unsigned images.

**4. Detect or Discuss Impact** — Some labs add detection, triage, or case study analysis when it helps learners connect the attack to real work. Not every lab requires formal detection content.

## Highlights

- **6 real-world case studies** dissecting SolarWinds, Log4Shell, xz-utils, Codecov, event-stream, and Equifax
- **Multiple perspectives** across SOC, engineering, operations, and leadership
- **Placement test** to skip what you already know
- **Full isolation** with private registries (PyPI, npm, OCI), Gitea, and a pre-configured workstation

## Optional CLI Commands

Most learners can ignore the CLI after startup and work directly in the browser. If you want host-side helper commands, `weaklink` provides these:

```bash
weaklink shell             # Open a shell in the workstation
weaklink info <lab-id>     # Show lab metadata
weaklink hint <lab-id>     # Get a hint if you are stuck
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
