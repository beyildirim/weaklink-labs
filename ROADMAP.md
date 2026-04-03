# WeakLink Labs Roadmap

**Hands-on supply chain security training — 55 labs across 9 tiers.**

All labs run locally on minikube. No cloud accounts required.

---

## Tier 0 — Foundations

*Understand the building blocks before breaking them.*

- [x] **0.1 How Version Control Works** — Git internals, commit signing, and trust boundaries
- [x] **0.2 How Package Managers Work** — Resolution, registries, and the install lifecycle
- [x] **0.3 How Containers Work** — Images, layers, and runtime isolation
- [ ] **0.4 How CI/CD Works** — Pipeline triggers, secrets, and execution models
- [ ] **0.5 Artifacts & Registries** — Package publishing, distribution, and integrity checks

## Tier 1 — Package Security

*Attack and defend the dependency layer.*

- [x] **1.1 Dependency Resolution** — How package managers choose versions and resolve conflicts
- [x] **1.2 Dependency Confusion** — Exploiting private/public namespace collisions
- [x] **1.3 Typosquatting** — Publishing malicious packages with similar names
- [x] **1.4 Lockfile Injection** — Tampering with lockfiles to redirect installs
- [x] **1.5 Manifest Confusion** — Exploiting mismatches between manifest and published content
- [x] **1.6 Phantom Dependencies** — Using packages that aren't declared but resolve anyway

## Tier 2 — Build & CI/CD

*Compromise the pipeline, compromise everything.*

- [ ] **2.1 Pipeline Anatomy** — Dissecting CI/CD workflows and identifying attack surfaces
- [ ] **2.2 Direct PPE** — Poisoned Pipeline Execution via direct code changes
- [ ] **2.3 Indirect PPE** — Poisoned Pipeline Execution through configuration manipulation
- [ ] **2.4 Secret Exfiltration** — Extracting credentials from CI/CD environments
- [ ] **2.5 Self-Hosted Runner Attacks** — Exploiting persistent build infrastructure
- [ ] **2.6 GitHub Actions Injection** — Injecting commands through untrusted input in workflows
- [ ] **2.7 Build Cache Poisoning** — Manipulating cached artifacts to inject malicious code
- [ ] **2.8 workflow_run Attacks** — Abusing privileged workflow triggers for elevated access

## Tier 3 — Container Security

*From image to exploit.*

- [ ] **3.1 Image Internals** — Understanding layers, manifests, and image configuration
- [ ] **3.2 Tag Mutability** — Exploiting mutable tags to swap trusted images
- [ ] **3.3 Base Image Poisoning** — Compromising upstream base images to infect dependents
- [ ] **3.4 Registry Confusion** — Redirecting pulls to attacker-controlled registries
- [ ] **3.5 Layer Injection** — Inserting malicious layers into existing images
- [ ] **3.6 Multi-Stage Build Leaks** — Extracting secrets left behind in intermediate stages

## Tier 4 — Artifact Integrity

*Signatures, attestations, and the gaps between them.*

- [ ] **4.1 SBOM Contents** — What goes into an SBOM and why it matters
- [ ] **4.2 SBOM Gaps** — Finding what SBOMs miss and how attackers exploit blind spots
- [ ] **4.3 Signing Fundamentals** — Code and artifact signing with Sigstore and GPG
- [ ] **4.4 Attestation & SLSA** — Building provenance chains with in-toto and SLSA
- [ ] **4.5 Signature Bypass** — Circumventing signing verification through implementation flaws
- [ ] **4.6 Attestation Forgery** — Crafting fake provenance that passes validation
- [ ] **4.7 SBOM Tampering** — Modifying SBOMs to hide malicious components

## Tier 5 — IaC Supply Chain

*Infrastructure code has dependencies too.*

- [ ] **5.1 Helm Resolution** — How Helm resolves charts, repositories, and dependencies
- [ ] **5.2 Helm Poisoning** — Injecting malicious templates through compromised charts
- [ ] **5.3 Terraform Module Attacks** — Exploiting remote module sources and registry trust
- [ ] **5.4 Ansible Galaxy** — Attacking role and collection distribution channels
- [ ] **5.5 K8s Admission Bypass** — Circumventing admission controllers and policy enforcement

## Tier 6 — Advanced & Emerging

*Frontier attacks and real-world case studies.*

- [ ] **6.1 AI/ML Model Supply Chain** — Compromising model registries and serialization formats
- [ ] **6.2 Dataset Poisoning** — Injecting malicious data through upstream training sets
- [ ] **6.3 Firmware Supply Chain** — Attacking firmware update and distribution mechanisms
- [ ] **6.4 Multi-Vector Chained Attacks** — Combining techniques across tiers for full compromise
- [ ] **6.5 Case Study: xz-utils** — Social engineering a backdoor into critical infrastructure
- [ ] **6.6 Case Study: SolarWinds** — Build system compromise at scale
- [ ] **6.7 Case Study: Codecov** — CI credential theft through a bash uploader
- [ ] **6.8 Case Study: event-stream** — Targeted supply chain attack via maintainer handoff

## Tier 7 — Detection & Response

*Find it, triage it, fix it.*

- [ ] **7.1 Detection Rules** — Writing signatures and heuristics for supply chain attacks
- [ ] **7.2 Incident Triage** — Rapid scoping and impact assessment for package compromises
- [ ] **7.3 IR Playbook** — Step-by-step incident response for supply chain breaches
- [ ] **7.4 Tool Evaluation** — Assessing SCA, SAST, and supply chain security tools
- [ ] **7.5 Threat Modeling** — Mapping supply chain threats with structured methodologies

## Tier 8 — Organizational

*Policy, compliance, and program building.*

- [ ] **8.1 SLSA Deep Dive** — Implementing SLSA levels in real build systems
- [ ] **8.2 SSDF & NIST** — Applying NIST SP 800-218 Secure Software Development Framework
- [ ] **8.3 Executive Order 14028** — Understanding federal supply chain security requirements
- [ ] **8.4 Vendor Assessment** — Evaluating third-party software supply chain practices
- [ ] **8.5 Building a Program** — Standing up an organizational supply chain security program

---

**Progress: 9 / 55 labs available**

| Tier | Topic | Labs | Status |
|------|-------|------|--------|
| 0 | Foundations | 5 | 3 available |
| 1 | Package Security | 6 | 6 available |
| 2 | Build & CI/CD | 8 | Planned |
| 3 | Container Security | 6 | Planned |
| 4 | Artifact Integrity | 7 | Planned |
| 5 | IaC Supply Chain | 5 | Planned |
| 6 | Advanced & Emerging | 8 | Planned |
| 7 | Detection & Response | 5 | Planned |
| 8 | Organizational | 5 | Planned |
