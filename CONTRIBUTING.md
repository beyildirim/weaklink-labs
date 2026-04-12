# Contributing to WeakLink Labs

Thanks for your interest in contributing! This guide explains how to add a new lab and test it.

## Architecture Overview

The main contributor path uses `make start`, which brings up the Minikube + Helm environment. The Helm chart at `helm/weaklink-labs/` deploys everything: the workstation, lab services (Gitea, PyPI servers, Verdaccio, registry), the MkDocs guide, and a setup job that seeds lab content. Docker images are built locally from `images/`.

## Architecture Gate

Before adding a lab, feature, or service, check it against these rules:

- Teach one primary trust failure. If a proposal tries to teach multiple attacks or unrelated lessons at once, split it or cut it down.
- Preserve the learner flow: start the platform, open the guide in the browser, use the built-in terminal.
- Keep the phase flow coherent. `UNDERSTAND`, `BREAK`, `DEFEND`, and `DETECT` or impact should all reinforce the same core lesson.
- Prefer tightening existing labs over adding parallel experiences, extra workflow branches, or platform mechanics.
- Add infrastructure only when it has a direct teaching payoff that cannot be achieved with the existing services.
- Treat Tier `0` through Tier `5` as the core path. Changes for Tier `6` and Tier `7` should be deliberate, not default expansion.

## Lab Structure

Every lab lives under `labs/tier-N-topic/N.X-lab-name/`:

```
labs/tier-1-package-security/1.2-dependency-confusion/
├── lab.yml              # Metadata (required)
├── verify.sh            # Completion check (required fallback)
├── verify.py            # Preferred Python verifier for platform-owned checks
├── hints/               # Progressive hints
│   ├── hint-1.md
│   ├── hint-2.md
│   └── hint-3.md
├── src/                 # Application code, configs, vulnerable packages
└── solution/            # Reference solution
```

Each lab also has a corresponding guide section under `guide/docs/labs/tier-N/N.X-lab-name/`.

## Adding a New Lab

### 1. Create the lab directory

```bash
mkdir -p labs/tier-N-topic/N.X-lab-name/{src,hints,solution}
```

Create the required files: `lab.yml`, one verifier entrypoint (`verify.py` preferred, `verify.sh` supported), and `hints/hint-1.md` through `hint-3.md`.

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
phase_detect: "What the learner detects in phase 4"
```

### 3. Write verification

- Prefer `verify.py` for platform-owned validation logic
- Keep `verify.sh` when the shell is part of the lesson or you need compatibility with older labs
- Either verifier must return exit code 0 on success and non-zero on failure
- Print clear messages about what passed and what failed
- Check the **defense**, not just the attack (the user should have fixed the issue)

### 4. Optional lab initialization hook

- Prefer `src/lab_init.py` for behind-the-scenes setup logic
- Keep `src/lab-init.sh` when you need compatibility or the setup is intentionally shell-based
- Learner-visible scripts under `src/scripts/` should stay in the language that teaches the lesson best

### 5. Add the lab guide page

Create the lab guide under `guide/docs/labs/tier-N/N.X-lab-name/`. Most labs use `index.md`, `understand.md`, `break.md`, `defend.md`, and `detect.md`. The guide follows the 4-phase structure using admonitions to mark phase transitions:

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
make shell
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

### 6. Seed lab content (if needed)

If your lab needs packages, repos, or other content pre-loaded into the lab services, add the seeding logic to the lab-setup image. The setup job runs as a Kubernetes Job during Helm install and populates Gitea, PyPI servers, Verdaccio, and the container registry with lab content.

The lab-setup image copies everything from `labs/` into the image at build time (see `images/lab-setup/Dockerfile`), so your `src/` directory contents are available inside the job.

### 7. Add a new service (if needed)

If your lab requires a service that doesn't already exist in the Helm chart (Gitea, PyPI, Verdaccio, registry):

1. Add its config to `helm/weaklink-labs/values.yaml`
2. Create deployment + service templates in `helm/weaklink-labs/templates/`
3. Gate it behind a tier feature flag if it's tier-specific

### 8. Tier feature flags

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
    make start
    ```

    This builds the Docker images, starts Minikube, and deploys the Helm chart.

2. Open the guide in your browser (served on `http://localhost:8000`).

3. Work through your lab following the guide.

4. Verify completion:

    ```bash
    ./cli/weaklink verify <lab-id>
    ```

5. Confirm all 4 phases work end-to-end: understand, break, defend, detect.

## PR Process

1. Fork the repo
2. Create your lab following the steps above
3. Test it locally: start the environment, complete all 4 phases, run verify
4. Submit a PR with:
    - What the lab teaches
    - Which tier/module it belongs to
    - Any new services or dependencies added
5. Ensure the lab is self-contained. No manual setup steps outside of what the Helm chart and setup job handle
