# Contributing to WeakLink Labs

Thanks for your interest in contributing! This guide explains how to add a new lab and test it.

## Architecture Overview

WeakLink Labs runs on Minikube. The Helm chart at `helm/weaklink-labs/` deploys everything: the workstation, lab services (Gitea, PyPI servers, Verdaccio, registry), the MkDocs guide, and a setup job that seeds lab content. Docker images are built locally from `images/`.

## Lab Structure

Every lab lives under `labs/tier-N-topic/N.X-lab-name/`:

```
labs/tier-1-package-security/1.2-dependency-confusion/
├── lab.yml              # Metadata (required)
├── verify.sh            # Completion check (required)
├── hints/               # Progressive hints
│   ├── hint-1.md
│   ├── hint-2.md
│   └── hint-3.md
├── src/                 # Application code, configs, vulnerable packages
└── solution/            # Reference solution
```

Each lab also has a corresponding guide page at `guide/docs/labs/tier-N/N.X-lab-name.md`.

## Adding a New Lab

### 1. Create the lab directory

```bash
mkdir -p labs/tier-N-topic/N.X-lab-name/{src,hints,solution}
```

Create the required files: `lab.yml`, `verify.sh`, `hints/hint-1.md` through `hint-3.md`.

### 2. Write lab.yml

```yaml
id: "N.X"
title: "Your Lab Title"
tier: N
module: "topic-name"
prerequisites: ["N.Y"]
difficulty: beginner | intermediate | advanced
estimated_time: 30m
tags: ["relevant", "tags"]
phase_understand: "What the learner explores in phase 1"
phase_break: "What the learner attacks in phase 2"
phase_defend: "What the learner fixes in phase 3"
```

### 3. Write verify.sh

- Must return exit code 0 on success, non-zero on failure
- Print clear messages about what passed and what failed
- Check the **defense**, not just the attack (the user should have fixed the issue)

### 4. Add the lab guide page

Create `guide/docs/labs/tier-N/N.X-lab-name.md` using MkDocs Material format. The guide follows the 3-phase structure using admonitions to mark phase transitions:

```markdown
# Lab N.X: Title

<div class="lab-meta">
  <span>~30 minutes</span>
  <span>Intermediate</span>
  <span>Prerequisites: Lab N.Y</span>
</div>

Brief description of what this lab teaches and why it matters.

---

## Environment

| Service     | Address              |
|-------------|----------------------|
| Service UI  | `service:port`       |
| Login       | `user` / `password`  |

## Connect to the Workstation

```bash
./weaklink shell
```

---

!!! info "Phase 1: UNDERSTAND -- Title"

    **Goal:** What the learner will explore.

### Step 1: ...

---

!!! warning "Phase 2: BREAK -- Title"

    **Goal:** What the learner will attack.

### Step N: ...

---

!!! success "Phase 3: DEFEND -- Title"

    **Goal:** What the learner will fix.

### Step N: ...

---

## What You Learned

Summary mapping to real-world relevance.

## Further Reading

- [Link](url)
```

Then add the page to the nav in `guide/mkdocs.yml`.

### 5. Seed lab content (if needed)

If your lab needs packages, repos, or other content pre-loaded into the lab services, add the seeding logic to the lab-setup image. The setup job runs as a Kubernetes Job during Helm install and populates Gitea, PyPI servers, Verdaccio, and the container registry with lab content.

The lab-setup image copies everything from `labs/` into the image at build time (see `images/lab-setup/Dockerfile`), so your `src/` directory contents are available inside the job.

### 6. Add a new service (if needed)

If your lab requires a service that doesn't already exist in the Helm chart (Gitea, PyPI, Verdaccio, registry):

1. Add its config to `helm/weaklink-labs/values.yaml`
2. Create deployment + service templates in `helm/weaklink-labs/templates/`
3. Gate it behind a tier feature flag if it's tier-specific

### 7. Tier feature flags

The Helm chart has tier toggles in `values.yaml`:

```yaml
tiers:
  tier0:
    enabled: true
  tier1:
    enabled: true
  tier2:
    enabled: false
  # ...
```

If your lab's services should only deploy when the tier is enabled, use the appropriate conditional in the Helm templates.

## Testing Locally

1. Start the environment:

    ```bash
    ./weaklink start
    ```

    This builds the Docker images, starts Minikube, and deploys the Helm chart.

2. Open the guide in your browser (served on `localhost:30080`).

3. Work through your lab following the guide.

4. Verify completion:

    ```bash
    ./weaklink verify <lab-id>
    ```

5. Confirm all 3 phases work end-to-end: understand, break, defend.

## PR Process

1. Fork the repo
2. Create your lab following the steps above
3. Test it locally: start the environment, complete all 3 phases, run verify
4. Submit a PR with:
    - What the lab teaches
    - Which tier/module it belongs to
    - Any new services or dependencies added
5. Ensure the lab is self-contained. No manual setup steps outside of what the Helm chart and setup job handle
