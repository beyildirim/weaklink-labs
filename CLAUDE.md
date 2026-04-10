# WeakLink Labs

Supply chain security training platform. 50 labs, 8 tiers, runs on minikube.

## Architecture

- **Runtime:** K8s (minikube) for full experience, Docker Compose for quick start. Workstation pod/container mounts the Docker socket for container labs.
- **Guide:** MkDocs Material, served as a pod, accessed via port-forward at localhost:8000
- **Terminal:** ttyd baked into workstation image, port 7681
- **Registries:** pypi-private, pypi-public, verdaccio, gitea, OCI registry (all K8s services)
- **Verify API:** verify-server.py on port 7682, called by the guide terminal panel
- **CLI:** `cli/weaklink` (bash). Commands: shell, verify, hint, info, path, status, logs, report, assess, reset

## Key Directories

```
helm/weaklink-labs/          Helm chart (all K8s resources)
guide/docs/                  MkDocs site content
guide/docs/labs/tier-N/      Lab guide pages (50 total)
guide/docs/stylesheets/      CSS
guide/docs/javascripts/      JS (tier-colors.js, terminal-panel.js)
guide/mkdocs.yml             MkDocs config
images/workstation/          Workstation Dockerfile (Python+Node+ttyd)
images/lab-setup/            Lab seeder (setup-labs.sh)
images/guide/                MkDocs Dockerfile
labs/tier-N-*/               Lab source files (lab.yml, verify.sh, hints/, src/)
cli/weaklink                 CLI script
start.sh / stop.sh           Lifecycle scripts (minikube path)
docker-compose.yml           Quick start (Docker Compose path)
Makefile                     Developer convenience targets
scripts/                     Operational utilities (sign-images.sh)
```

## Lab Guide Page Structure

All labs use the phase-per-page structure: `guide/docs/labs/tier-N/N.X-lab-name/` with separate files:

- `index.md` (title, lab-meta, phase stepper nav, attack flow mermaid, environment table)
- `understand.md` (Phase 1)
- `break.md` (Phase 2)
- `defend.md` (Phase 3)
- `detect.md` (Phase 4)

Case study labs (6.5-6.10) use: UNDERSTAND/ANALYZE/LESSONS/DETECT
Tier 7 labs use: UNDERSTAND/INVESTIGATE/VALIDATE/IMPROVE
## Rules

- Never use `--` as punctuation in prose. Use periods, commas, or restructure.
- Never add inline Sigma/Splunk/KQL detection rules to guide pages. Phase 4 DETECT is conceptual only (bullet points, indicator tables, MITRE mapping).
- Never add Co-Authored-By or AI attribution to commits.
- Admonitions: use `???+` (expanded) for phases 1-3, `???` (collapsed) for phase 4/SOC/CI.
- Prerequisites in guide pages must be hyperlinked: `<a href="../../tier-1/1.2-dependency-confusion/">Lab 1.2</a>`
- Mermaid diagrams: `graph LR`, simple, no classDef styling.
- MkDocs nav: 3 tabs only (Home, Labs, Resources). Tiers nested under Labs in order 0-7.
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

- Don't duplicate Docker Compose definitions. Root docker-compose.yml is canonical; .devcontainer extends it.
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
