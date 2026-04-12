<div class="hero">
<h1>WeakLink Labs</h1>
<p class="tagline">You're only as strong as your weakest link.</p>
<p class="subtitle">Hands-on supply chain security training for people who need to understand how software supply chains work, break, and get defended.</p>
<p><a href="getting-started.md">Get Started</a></p>
</div>

---

## What is WeakLink Labs?

WeakLink Labs is a self-contained training environment for learning **software supply chain security** by doing. Most attack-focused labs follow a simple pattern:

<div class="phase-flow">
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

> **Local-Only Training Environment**
>
> WeakLink Labs is built for local use on your machine or in a Codespace. It is not hardened for public Internet exposure or shared multi-user hosting, and the labs intentionally include malicious packages, weak defaults, and vulnerable configurations for training.

---

## Training Tiers

**Core learning path:** Tier `0` through Tier `5`

**Advanced branches:** Tier `6` and Tier `7`

<div class="tier-grid">

<div class="tier-card">
<span class="tier-number">TIER 0</span>
<h3><a href="labs/tier-0/0.1-version-control/index.md">Foundations</a></h3>
<p>Version control, package managers, and containers. How the building blocks work, and where the cracks are.</p>
<div class="lab-count">5 labs &middot; ~2 hours</div>
</div>

<div class="tier-card">
<span class="tier-number">TIER 1</span>
<h3><a href="labs/tier-1/1.1-dependency-resolution/index.md">Package Security</a></h3>
<p>Dependency confusion, typosquatting, lockfile injection, manifest confusion, and phantom dependencies.</p>
<div class="lab-count">6 labs &middot; ~3 hours</div>
</div>

<div class="tier-card">
<span class="tier-number">TIER 2</span>
<h3><a href="labs/tier-2/2.1-cicd-fundamentals/index.md">Build &amp; CI/CD</a></h3>
<p>Poisoned Pipeline Execution, secret exfiltration, GitHub Actions injection, runner attacks, and build cache poisoning.</p>
<div class="lab-count">8 labs &middot; ~5 hours</div>
</div>

<div class="tier-card">
<span class="tier-number">TIER 3</span>
<h3><a href="labs/tier-3/3.1-image-internals/index.md">Container Security</a></h3>
<p>Tag mutability, base image poisoning, registry confusion, layer injection, and multi-stage build leaks.</p>
<div class="lab-count">6 labs &middot; ~3 hours</div>
</div>

<div class="tier-card">
<span class="tier-number">TIER 4</span>
<h3><a href="labs/tier-4/4.1-sbom-contents/index.md">SBOM &amp; Signing</a></h3>
<p>SBOMs, signing with Sigstore and GPG, SLSA provenance, attestation forgery, and SBOM tampering.</p>
<div class="lab-count">7 labs &middot; ~4 hours</div>
</div>

<div class="tier-card">
<span class="tier-number">TIER 5</span>
<h3><a href="labs/tier-5/5.1-helm-resolution/index.md">IaC Supply Chain</a></h3>
<p>Helm poisoning, Terraform module attacks, Ansible Galaxy, and admission controller bypass.</p>
<div class="lab-count">5 labs &middot; ~3 hours</div>
</div>

<div class="tier-card">
<span class="tier-number">TIER 6</span>
<h3><a href="labs/tier-6/6.1-ml-model-supply-chain/index.md">Case Studies &amp; Frontier Attacks</a></h3>
<p>AI/ML supply chain, firmware attacks, and major case studies. Advanced branch, not the default next step for every learner.</p>
<div class="lab-count">10 labs &middot; ~6 hours</div>
</div>

<div class="tier-card">
<span class="tier-number">TIER 7</span>
<h3><a href="labs/tier-7/7.2-incident-triage/index.md">Response &amp; Threat Modeling</a></h3>
<p>Incident triage, IR playbooks, and threat modeling. Advanced branch for SOC and response-oriented learners.</p>
<div class="lab-count">3 labs &middot; ~2 hours</div>
</div>

</div>

---

<p align="center"><a href="getting-started.md">Get Started</a></p>
