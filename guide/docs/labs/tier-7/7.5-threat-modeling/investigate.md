# Lab 7.5: Threat Modeling for Software Supply Chains

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Investigate</span>
  <span class="phase-arrow">›</span>
  <a href="../validate/" class="phase-step upcoming">Validate</a>
  <span class="phase-arrow">›</span>
  <a href="../improve/" class="phase-step upcoming">Improve</a>
</div>

**Goal:** Map the complete supply chain for a sample application, marking every trust boundary.

## Step 1: The sample application

- **Language**: Python (backend), Node.js (frontend)
- **Source**: GitHub (private repository)
- **Build**: GitHub Actions CI/CD
- **Dependencies**: PyPI (Python), npm (Node.js)
- **Artifacts**: Docker container images
- **Registry**: GitHub Container Registry (ghcr.io)
- **Deployment**: Kubernetes cluster via ArgoCD

## Step 2: Trust boundary map

```
   Developer                         External Registries
   ┌─────────┐                       ┌──────────────────┐
   │ Laptop  │──── git push ────────>│  GitHub (source)  │
   │         │     [TB-1]            │                   │
   └─────────┘                       └────────┬──────────┘
                                              │
                                     [TB-2] PR merge trigger
                                              │
                                     ┌────────▼──────────┐
   ┌─────────────┐                   │  GitHub Actions    │
   │ Public PyPI  │<── pip install ──│  (CI runner)       │
   │             │     [TB-3]        │                    │
   └─────────────┘                   │  Secrets injected  │
   ┌─────────────┐                   │  [TB-4]            │
   │ Public npm   │<── npm install ──│                    │
   │             │     [TB-5]        └────────┬───────────┘
   └─────────────┘                            │
                                     [TB-6] docker push
                                              │
                                     ┌────────▼──────────┐
                                     │ GitHub Container   │
                                     │ Registry (ghcr.io) │
                                     └────────┬───────────┘
                                              │
                                     [TB-7] ArgoCD sync
                                              │
                                     ┌────────▼──────────┐
                                     │ Kubernetes         │
                                     │ (production)       │
                                     └────────────────────┘
```

## Step 3: Catalog trust boundaries

| ID | Trust Boundary | Data Crossing |
|----|---------------|---------------|
| TB-1 | Developer push | Source code, commits, signatures |
| TB-2 | CI trigger | Workflow definition, trigger event |
| TB-3 | Python dependency fetch | Python packages (.tar.gz, .whl) |
| TB-4 | Secret injection | API keys, tokens, credentials |
| TB-5 | Node.js dependency fetch | npm packages (.tgz) |
| TB-6 | Artifact publish | Docker images, tags |
| TB-7 | Deployment sync | Container images, manifests |

## Step 4: Save the map for verification

```bash
mkdir -p /app/work

cat > /app/work/supply-chain-map.md <<'EOF'
# Supply Chain Map

## Trust boundaries

- Trust boundary TB-1: Developer push -> source repository
- Trust boundary TB-2: Source repository -> CI trigger
- Trust boundary TB-3: CI runner -> Python dependency fetch
- Trust boundary TB-4: CI runner -> secret injection
- Trust boundary TB-5: CI runner -> Node.js dependency fetch
- Trust boundary TB-6: CI runner -> artifact publish
- Trust boundary TB-7: Artifact registry -> deployment sync

## Boundary catalog

| ID | Trust Boundary | Data Crossing |
|----|---------------|---------------|
| TB-1 | Developer push | Source code, commits, signatures |
| TB-2 | CI trigger | Workflow definition, trigger event |
| TB-3 | Python dependency fetch | Python packages (.tar.gz, .whl) |
| TB-4 | Secret injection | API keys, tokens, credentials |
| TB-5 | Node.js dependency fetch | npm packages (.tgz) |
| TB-6 | Artifact publish | Docker images, tags |
| TB-7 | Deployment sync | Container images, manifests |
EOF
```

---

<details open>
<summary>Checkpoint</summary>

You should have 7 trust boundaries mapped in `/app/work/supply-chain-map.md`. For each, you should be able to name what data crosses and in which direction. This map is the input to STRIDE analysis.

</details>
