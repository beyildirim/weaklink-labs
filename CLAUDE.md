# WeakLink Labs

Supply chain security training platform. 62 labs, 10 tiers, runs on minikube.

## Architecture

- **Runtime:** K8s only (minikube). No Docker Compose for labs. Workstation pod mounts the Docker socket for container labs.
- **Guide:** MkDocs Material, served as a pod, accessed via port-forward at localhost:8000
- **Terminal:** ttyd baked into workstation image, port 7681
- **Registries:** pypi-private, pypi-public, verdaccio, gitea, OCI registry (all K8s services)
- **Verify API:** verify-server.py on port 7682, called by verify-button.js in the guide UI
- **CLI:** `cli/weaklink` (bash). Commands: shell, verify, hint, info, path, status, logs, report, assess, reset

## Key Directories

```
helm/weaklink-labs/          Helm chart (all K8s resources)
guide/docs/                  MkDocs site content
guide/docs/labs/tier-N/      Lab guide pages (62 total)
guide/docs/stylesheets/      CSS
guide/docs/javascripts/      JS (tier-colors.js, verify-button.js)
guide/mkdocs.yml             MkDocs config
images/workstation/          Workstation Dockerfile (Python+Node+ttyd)
images/lab-setup/            Lab seeder (setup-labs.sh)
images/guide/                MkDocs Dockerfile
labs/tier-N-*/               Lab source files (lab.yml, verify.sh, hints/, src/)
cli/weaklink                 CLI script
start.sh / stop.sh           Lifecycle scripts
```

## Lab Guide Page Structure

Every guide page at `guide/docs/labs/tier-N/*.md` follows this structure:
1. Title + `<div class="lab-meta">` (time, difficulty, prerequisites)
2. Intro paragraph (2-3 sentences)
3. `### Attack Flow` with ```mermaid diagram (graph LR, 4-7 nodes, no classDef)
4. `## Environment` table
5. `## Connect to the Workstation` + terminal embed iframe
6. `???+ info "Phase 1: UNDERSTAND"` (collapsible, expanded)
7. `???+ warning "Phase 2: BREAK"` (collapsible, expanded)
8. `???+ success "Phase 3: DEFEND"` (collapsible, expanded)
9. `??? danger "Phase 4: DETECT"` (collapsible, collapsed)
10. `??? tip "SOC Relevance"` (collapsed)
11. `??? example "CI Integration"` (collapsed)
12. `## What You Learned`
13. `## Further Reading`

Lab 1.2 uses a phase-per-page structure (directory with index.md, understand.md, break.md, defend.md, detect.md) as the prototype for splitting large labs into separate pages.

Case study labs (6.5-6.10) use: UNDERSTAND/ANALYZE/LESSONS/DETECT
Tier 7 labs use: UNDERSTAND/INVESTIGATE/VALIDATE/IMPROVE
Tier 8 labs use: UNDERSTAND/ASSESS/PLAN/DOCUMENT

## Rules

- Never use `--` as punctuation in prose. Use periods, commas, or restructure.
- Never add inline Sigma/Splunk/KQL detection rules to guide pages. Phase 4 DETECT is conceptual only (bullet points, indicator tables, MITRE mapping).
- Never add Co-Authored-By or AI attribution to commits.
- Admonitions: use `???+` (expanded) for phases 1-3, `???` (collapsed) for phase 4/SOC/CI.
- Prerequisites in guide pages must be hyperlinked: `[Lab 1.2](../tier-1/1.2-dependency-confusion.md)`
- Mermaid diagrams: `graph LR`, simple, no classDef styling.
- MkDocs nav: 3 tabs only (Home, Labs, Resources). Tiers nested under Labs in order 0-9.
- Target audience: SOC analysts, security engineers, DevSecOps, DevOps. Not just one persona.
- The `fence_code_format` is correct for Mermaid in MkDocs Material (not fence_mermaid_format).

## Helm Chart

- Namespace: `weaklink`
- Services: guide (NodePort 30080), pypi-private (8080), pypi-public (8080), verdaccio (4873), gitea (3000), registry (5000), workstation (7681 for ttyd, 7682 for verify API)
- Lab-setup is a Helm post-install hook Job
- Verdaccio needs explicit `VERDACCIO_PORT` env var (K8s service env collision)
- Workstation has no `command:` override in Helm (Dockerfile CMD runs ttyd + sleep)
- Images use `pullPolicy: Never` (built locally into minikube docker)
- On macOS: use port-forward, not NodePort (Docker driver can't reach minikube IP)

## CLI Features

- `weaklink report` (pretty/--json/--csv/--team)
- `weaklink assess` (10-question placement test, skip Tier 0 at 8/10)
- Progress stored in `~/.weaklink/`

## What NOT to Do

- Don't add Docker Compose files. K8s only.
- Don't add full detection rules inline. Keep Phase 4 conceptual.
- Don't make the MkDocs nav crowded. 3 tabs, tiers nested.
- Don't use `navigation.expand` in mkdocs.yml (makes sidebar too long).
- Don't use `fence_mermaid_format` (crashes the MkDocs Material image).
- Don't guess at infrastructure details. Check actual files.

## Strategy (not in repo)

- Blog strategy: ~/Desktop/weaklink-labs-strategy/blog-strategy.md
- Conference CFPs: ~/Desktop/weaklink-labs-strategy/conference-cfps.md
- Planned domain: weaklink-labs.dev
- GitHub user: beyildirim
