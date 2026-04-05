<div class="hero" markdown>

# WeakLink Labs

<p class="tagline">You're only as strong as your weakest link.</p>
<p class="subtitle">Hands-on supply chain security training. Understand how attacks work. Execute them. Then build the defenses.</p>

[Get Started](getting-started.md){ .cta-button }

</div>

---

## What is WeakLink Labs?

WeakLink Labs is a self-contained training environment for learning **software supply chain security** by doing. Every lab follows four phases:

<div class="phase-flow" markdown>
  <span class="phase-step understand">1. Understand</span>
  <span class="arrow">&rarr;</span>
  <span class="phase-step break">2. Break</span>
  <span class="arrow">&rarr;</span>
  <span class="phase-step defend">3. Defend</span>
  <span class="arrow">&rarr;</span>
  <span class="phase-step defend">4. Detect</span>
</div>

You don't learn security by reading about it. You learn by **exploiting real vulnerabilities** in a safe environment, building the defenses that stop them, and writing the detection rules that catch them.

### Who is this for?

- **SOC analysts** who triage alerts but have never seen the attacks behind them
- **Security engineers** looking for hands-on training materials
- **DevSecOps / DevOps teams** responsible for securing CI/CD pipelines
- **Developers** who want to understand what's targeting their dependency chains
- **Pentesters** who want to add supply chain techniques to their toolkit

### What's inside?

63 labs across 10 tiers. All labs run inside a Kubernetes cluster on your machine. Every registry, Git server, and build tool is local. Nothing touches the internet. You get a full workstation with all the tools pre-installed.

---

## Training Tiers

<div class="tier-grid" markdown>

<div class="tier-card" markdown>
<span class="tier-number">TIER 0</span>

### [Foundations](labs/tier-0/0.1-version-control.md)

Version control, package managers, and containers. How the building blocks work, and where the cracks are.

<div class="lab-count">5 labs &middot; ~2 hours</div>
</div>

<div class="tier-card" markdown>
<span class="tier-number">TIER 1</span>

### [Package Security](labs/tier-1/1.1-dependency-resolution.md)

Dependency confusion, typosquatting, lockfile injection, manifest confusion, and phantom dependencies.

<div class="lab-count">6 labs &middot; ~3 hours</div>
</div>

<div class="tier-card" markdown>
<span class="tier-number">TIER 2</span>

### [Build & CI/CD](labs/tier-2/2.1-cicd-fundamentals.md)

Poisoned Pipeline Execution, secret exfiltration, GitHub Actions injection, runner attacks, and build cache poisoning.

<div class="lab-count">9 labs</div>
</div>

<div class="tier-card" markdown>
<span class="tier-number">TIER 3</span>

### [Container Security](labs/tier-3/3.1-image-internals.md)

Tag mutability, base image poisoning, registry confusion, layer injection, and multi-stage build leaks.

<div class="lab-count">6 labs</div>
</div>

<div class="tier-card" markdown>
<span class="tier-number">TIER 4</span>

### [SBOM & Signing](labs/tier-4/4.1-sbom-contents.md)

SBOMs, signing with Sigstore and GPG, SLSA provenance, attestation forgery, and SBOM tampering.

<div class="lab-count">7 labs</div>
</div>

<div class="tier-card" markdown>
<span class="tier-number">TIER 5</span>

### [IaC Supply Chain](labs/tier-5/5.1-helm-resolution.md)

Helm poisoning, Terraform module attacks, Ansible Galaxy, and admission controller bypass.

<div class="lab-count">5 labs</div>
</div>

<div class="tier-card" markdown>
<span class="tier-number">TIER 6</span>

### [Case Studies & Frontier Attacks](labs/tier-6/6.1-ml-model-supply-chain.md)

AI/ML supply chain, firmware attacks, and case studies: xz-utils, SolarWinds, Log4Shell, and more.

<div class="lab-count">10 labs</div>
</div>

<div class="tier-card" markdown>
<span class="tier-number">TIER 7</span>

### [Detection & Response](labs/tier-7/7.1-detection-rules.md)

Detection engineering, incident triage, IR playbooks, tool evaluation, and threat modeling.

<div class="lab-count">5 labs</div>
</div>

<div class="tier-card" markdown>
<span class="tier-number">TIER 8</span>

### [Policy & Program Building](labs/tier-8/8.1-slsa-deep-dive.md)

SLSA, SSDF, EO 14028, vendor assessment, and building a supply chain security program.

<div class="lab-count">6 labs</div>
</div>

<div class="tier-card" markdown>
<span class="tier-number">TIER 9</span>

### [Cloud Supply Chain](labs/tier-9/9.1-cloud-marketplace-poisoning.md)

Marketplace poisoning, serverless attacks, cloud CI/CD exploitation, and IAM chain abuse.

<div class="lab-count">4 labs</div>
</div>

</div>

---

<div style="text-align: center; margin: 2rem 0;" markdown>

[Get Started](getting-started.md){ .cta-button }

</div>
