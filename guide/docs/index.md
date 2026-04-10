<div class="hero" markdown>

# WeakLink Labs

<p class="tagline">You're only as strong as your weakest link.</p>
<p class="subtitle">Hands-on supply chain security training for people who need to understand how software supply chains work, break, and get defended.</p>

[Get Started](getting-started.md){ .cta-button }

</div>

---

## What is WeakLink Labs?

WeakLink Labs is a self-contained training environment for learning **software supply chain security** by doing. Most attack-focused labs follow a simple pattern:

<div class="phase-flow" markdown>
  <span class="phase-step understand">1. Understand</span>
  <span class="arrow">&rarr;</span>
  <span class="phase-step break">2. Break</span>
  <span class="arrow">&rarr;</span>
  <span class="phase-step defend">3. Defend</span>
  <span class="arrow">&rarr;</span>
  <span class="phase-step detect">4. Detect</span>
</div>

You do not learn supply chain security by memorizing terms. You learn by seeing how normal systems work, breaking them in a safe environment, and understanding what reduces risk in practice. Some labs add detection, triage, or case-study analysis, but the core goal is judgment.

### Core values

- **Teach judgment first.** Focus on what the learner should notice, ask, and decide.
- **Keep the path simple.** Start the platform, open the browser, use the terminal.
- **Teach across roles.** The same risk should make sense to SOC, engineering, operations, and leadership.
- **Prefer realism over platform mechanics.** The labs matter more than achievements, ceremony, or workflow overhead.

### Who is this for?

- **SOC analysts** who triage alerts but have never seen the attacks behind them
- **Security engineers** looking for hands-on training materials
- **DevSecOps / DevOps teams** responsible for securing CI/CD pipelines
- **Developers** who want to understand what's targeting their dependency chains
- **Pentesters** who want to add supply chain techniques to their toolkit

### What's inside?

50 labs across 8 tiers. The main experience runs locally with a full workstation, private registries, a Git server, and supporting services. Most of the environment is local to your machine. Some setup paths pull prebuilt images to get you started faster.

The recommended mainline is **Tier 0 through Tier 5**. That path stays closest to the browser-first, hands-on supply chain learning model. **Tier 6 and Tier 7** are better treated as optional advanced branches: case studies, incident response, and threat modeling.

---

## Training Tiers

**Core learning path:** Tier `0` through Tier `5`

**Advanced branches:** Tier `6` and Tier `7`

<div class="tier-grid" markdown>

<div class="tier-card" markdown>
<span class="tier-number">TIER 0</span>

### [Foundations](labs/tier-0/0.1-version-control/index.md)

Version control, package managers, and containers. How the building blocks work, and where the cracks are.

<div class="lab-count">5 labs &middot; ~2 hours</div>
</div>

<div class="tier-card" markdown>
<span class="tier-number">TIER 1</span>

### [Package Security](labs/tier-1/1.1-dependency-resolution/index.md)

Dependency confusion, typosquatting, lockfile injection, manifest confusion, and phantom dependencies.

<div class="lab-count">6 labs &middot; ~3 hours</div>
</div>

<div class="tier-card" markdown>
<span class="tier-number">TIER 2</span>

### [Build & CI/CD](labs/tier-2/2.1-cicd-fundamentals/index.md)

Poisoned Pipeline Execution, secret exfiltration, GitHub Actions injection, runner attacks, and build cache poisoning.

<div class="lab-count">8 labs &middot; ~5 hours</div>
</div>

<div class="tier-card" markdown>
<span class="tier-number">TIER 3</span>

### [Container Security](labs/tier-3/3.1-image-internals/index.md)

Tag mutability, base image poisoning, registry confusion, layer injection, and multi-stage build leaks.

<div class="lab-count">6 labs &middot; ~3 hours</div>
</div>

<div class="tier-card" markdown>
<span class="tier-number">TIER 4</span>

### [SBOM & Signing](labs/tier-4/4.1-sbom-contents/index.md)

SBOMs, signing with Sigstore and GPG, SLSA provenance, attestation forgery, and SBOM tampering.

<div class="lab-count">7 labs &middot; ~4 hours</div>
</div>

<div class="tier-card" markdown>
<span class="tier-number">TIER 5</span>

### [IaC Supply Chain](labs/tier-5/5.1-helm-resolution/index.md)

Helm poisoning, Terraform module attacks, Ansible Galaxy, and admission controller bypass.

<div class="lab-count">5 labs &middot; ~3 hours</div>
</div>

<div class="tier-card" markdown>
<span class="tier-number">TIER 6</span>

### [Case Studies & Frontier Attacks](labs/tier-6/6.1-ml-model-supply-chain/index.md)

AI/ML supply chain, firmware attacks, and major case studies. Advanced branch, not the default next step for every learner.

<div class="lab-count">10 labs &middot; ~6 hours</div>
</div>

<div class="tier-card" markdown>
<span class="tier-number">TIER 7</span>

### [Response & Threat Modeling](labs/tier-7/7.2-incident-triage/index.md)

Incident triage, IR playbooks, and threat modeling. Advanced branch for SOC and response-oriented learners.

<div class="lab-count">3 labs &middot; ~2 hours</div>
</div>

</div>

---

<div style="text-align: center; margin: 2rem 0;" markdown>

[Get Started](getting-started.md){ .cta-button }

</div>
