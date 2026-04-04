# WeakLink Labs

**Hands-on supply chain security training for SOC analysts, security engineers, DevSecOps, and DevOps teams.**

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/beyildirim/weaklink-labs?quickstart=1)

---

## Quick Start

```bash
git clone https://github.com/beyildirim/weaklink-labs.git
cd weaklink-labs
./start.sh
```

Open **http://\<minikube-ip\>:30080** in your browser. The web UI guides you through every lab.

> `minikube ip` prints the address. On macOS/Codespaces, use `minikube service guide -n weaklink --url` instead.

## What You Get

A full Kubernetes training environment running on minikube:

- **Web UI** (MkDocs Material) with step-by-step lab instructions
- **Workstation pod** with pre-installed tools (git, pip, npm, docker CLI)
- **Private registries** (PyPI, npm/Verdaccio, OCI) to simulate real supply chains
- **Gitea** instance for version control labs
- All isolated in a `weaklink` namespace -- nothing touches your host

## How It Works

Every lab follows the same three-phase structure:

1. **UNDERSTAND** -- See the system working normally. Explore it. Know what it does.
2. **BREAK** -- Exploit a real vulnerability. See the impact firsthand.
3. **DEFEND** -- Apply the fix. Re-run the attack. It fails. You know why.

## Learning Path

| Tier | Topic | Labs | Prerequisites |
|------|-------|------|---------------|
| **0** | **Foundations** | Version control, package managers, containers, CI/CD | 5 | None |
| **1** | **Package Security** | Dependency confusion, typosquatting, lockfile attacks | 6 | Tier 0 |
| **2** | **Build & CI/CD** | Pipeline poisoning, secret exfiltration, runner attacks, GitLab CI | 9 | Tier 1 |
| **3** | **Container Security** | Image tampering, registry confusion, layer attacks | 6 | Tier 0 |
| **4** | **Artifact Integrity** | SBOMs, signing, attestations, and how to bypass them | 7 | Tier 2 |
| **5** | **IaC Supply Chain** | Helm, Terraform, Ansible, admission controllers | 5 | Tier 3 |
| **6** | **Advanced & Emerging** | AI/ML, case studies (xz, SolarWinds, Log4Shell, Equifax) | 10 | Tier 4 |
| **7** | **Detection & Response** | SIEM rules, incident triage, IR playbooks, threat modeling | 5 | Tier 5 |
| **8** | **Organizational** | SLSA, SSDF, SCVS, EO 14028, building a program | 6 | Tier 7 |
| **9** | **Cloud Supply Chain** | Marketplace poisoning, serverless, cloud CI/CD, IAM chains | 4 | Tier 2 |

## Web UI

<!-- TODO: Replace with actual screenshot -->
![WeakLink Labs Web UI](docs/screenshot-placeholder.png)

## CLI Reference

Drop into the workstation pod to interact with labs:

```bash
./weaklink shell          # Open a shell in the workstation pod
./weaklink status         # Show what's running in the cluster
```

Inside the workstation, the `weaklink` CLI is available:

```bash
weaklink path             # Show the learning roadmap and your progress
weaklink start <lab-id>   # Start a lab (e.g., weaklink start 1.2)
weaklink stop             # Stop the current lab
weaklink verify <lab-id>  # Check if you completed the lab
weaklink hint <lab-id>    # Get a progressive hint
weaklink reset <lab-id>   # Reset a lab to try again
weaklink info <lab-id>    # Show lab details and phases
weaklink status           # Show what's currently running
```

## Lifecycle

```bash
./start.sh                # Start minikube, build images, deploy Helm chart
./stop.sh                 # Tear down the Helm release and stop minikube
```

## Prerequisites

| Tool | Minimum version | Install |
|------|----------------|---------|
| [Docker](https://docs.docker.com/get-docker/) | 20.10+ | `brew install --cask docker` |
| [minikube](https://minikube.sigs.k8s.io/) | 1.30+ | `brew install minikube` |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | 1.27+ | `brew install kubectl` |
| [Helm](https://helm.sh/) | 3.12+ | `brew install helm` |

On GitHub Codespaces, all prerequisites are pre-installed.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the lab template and guidelines.

## License

[MIT](LICENSE)
