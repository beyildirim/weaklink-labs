# Hint 1: Mapping the Supply Chain

## The Standard Software Supply Chain

Map these stages left to right, identifying every trust boundary crossing:

```
Developer Workstation
    |
    v [TRUST BOUNDARY: code leaves developer machine]
Source Code Repository (GitHub/GitLab)
    |
    v [TRUST BOUNDARY: CI system clones and executes code]
CI/CD Build System (GitHub Actions, Jenkins, etc.)
    |  |
    |  +-- Pulls dependencies from package registries [TRUST BOUNDARY]
    |  +-- Pulls base images from container registries [TRUST BOUNDARY]
    |  +-- Executes build scripts defined in repository [TRUST BOUNDARY]
    |
    v [TRUST BOUNDARY: artifact published to registry]
Artifact Registry (Docker Hub, PyPI, npm, internal)
    |
    v [TRUST BOUNDARY: deployment system pulls artifact]
Deployment System (Kubernetes, AWS ECS, etc.)
    |
    v [TRUST BOUNDARY: artifact runs in production]
Production Environment
```

Each `[TRUST BOUNDARY]` is where you apply STRIDE.

Save the output as `/app/work/supply-chain-map.md`. The lab verifier looks for that exact file name.

## What Counts as a Trust Boundary?

A trust boundary exists wherever **data or code crosses from one trust domain to another**. Examples:
- Code goes from a developer's machine to a shared repository (authentication, authorization)
- A build system downloads a dependency from an external registry (provenance, integrity)
- A built artifact is pushed to a registry (signing, access control)
- An artifact is pulled into production (verification, admission control)

For each boundary, ask: "Who controls the data on each side? Can one side be compromised without the other knowing?"
