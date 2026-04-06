# WeakLink Labs Roadmap

**Hands-on supply chain security training — 63 labs across 10 tiers.**

All labs run locally on minikube. No cloud accounts required.

---

## How Every Lab Works

Every lab follows four phases:

1. **UNDERSTAND** — See the system working normally. Know what it does.
2. **BREAK** — Execute a real attack. See the impact firsthand.
3. **DEFEND** — Apply the fix. Re-run the attack. It fails. You know why.
4. **DETECT** — Learn what this attack looks like in your SIEM, EDR, and CI logs. Get detection rules you can use at work tomorrow.

Detection is not a separate skill you learn later — it is built into every lab from Tier 0 onward. Each lab ships with portable Sigma detection rules, MITRE ATT&CK mappings, and a SOC triage workflow. By the time you reach Tier 7, you will have already built detection coverage for every attack technique in the curriculum.

---

## Tier 0 — Foundations

*Understand the building blocks before breaking them.*

- [x] **0.1 How Version Control Works** — Git internals, commit signing, and trust boundaries
- [x] **0.2 How Package Managers Work** — Resolution, registries, and the install lifecycle
- [x] **0.3 How Containers Work** — Images, layers, and runtime isolation
- [x] **0.4 How CI/CD Works** — Pipeline triggers, secrets, and execution models
- [x] **0.5 Artifacts & Registries** — Package publishing, distribution, and integrity checks

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

- [x] **2.1 CI/CD Fundamentals** — Dissecting CI/CD workflows and identifying attack surfaces
- [x] **2.2 Direct PPE** — Poisoned Pipeline Execution via direct code changes
- [x] **2.3 Indirect PPE** — Poisoned Pipeline Execution through configuration manipulation
- [x] **2.4 Secret Exfiltration** — Extracting credentials from CI/CD environments
- [x] **2.5 Self-Hosted Runner Attacks** — Exploiting persistent build infrastructure
- [x] **2.6 GitHub Actions Injection** — Injecting commands through untrusted input in workflows
- [x] **2.7 Build Cache Poisoning** — Manipulating cached artifacts to inject malicious code
- [x] **2.8 workflow_run Attacks** — Abusing privileged workflow triggers for elevated access

## Tier 3 — Container Security

*From image to exploit.*

- [x] **3.1 Image Internals** — Understanding layers, manifests, and image configuration
- [x] **3.2 Tag Mutability** — Exploiting mutable tags to swap trusted images
- [x] **3.3 Base Image Poisoning** — Compromising upstream base images to infect dependents
- [x] **3.4 Registry Confusion** — Redirecting pulls to attacker-controlled registries
- [x] **3.5 Layer Injection** — Inserting malicious layers into existing images
- [x] **3.6 Multi-Stage Build Leaks** — Extracting secrets left behind in intermediate stages

## Tier 4 — Artifact Integrity

*Signatures, attestations, and the gaps between them.*

- [x] **4.1 SBOM Contents** — What goes into an SBOM and why it matters
- [x] **4.2 SBOM Gaps** — Finding what SBOMs miss and how attackers exploit blind spots
- [x] **4.3 Signing Fundamentals** — Code and artifact signing with Sigstore and GPG
- [x] **4.4 Attestation & SLSA** — Building provenance chains with in-toto and SLSA
- [x] **4.5 Signature Bypass** — Circumventing signing verification through implementation flaws
- [x] **4.6 Attestation Forgery** — Crafting fake provenance that passes validation
- [x] **4.7 SBOM Tampering** — Modifying SBOMs to hide malicious components

## Tier 5 — IaC Supply Chain

*Infrastructure code has dependencies too.*

- [x] **5.1 Helm Resolution** — How Helm resolves charts, repositories, and dependencies
- [x] **5.2 Helm Poisoning** — Injecting malicious templates through compromised charts
- [x] **5.3 Terraform Module Attacks** — Exploiting remote module sources and registry trust
- [x] **5.4 Ansible Galaxy** — Attacking role and collection distribution channels
- [x] **5.5 K8s Admission Bypass** — Circumventing admission controllers and policy enforcement

## Tier 6 — Advanced & Emerging

*Frontier attacks and real-world case studies.*

- [x] **6.1 AI/ML Model Supply Chain** — Compromising model registries and serialization formats
- [x] **6.2 Dataset Poisoning** — Injecting malicious data through upstream training sets
- [x] **6.3 Firmware Supply Chain** — Attacking firmware update and distribution mechanisms
- [x] **6.4 Multi-Vector Chained Attacks** — Combining techniques across tiers for full compromise
- [x] **6.5 Case Study: xz-utils** — Social engineering a backdoor into critical infrastructure
- [x] **6.6 Case Study: SolarWinds** — Build system compromise at scale
- [x] **6.7 Case Study: Codecov** — CI credential theft through a bash uploader
- [x] **6.8 Case Study: event-stream** — Targeted supply chain attack via maintainer handoff
- [x] **6.9 Case Study: Log4Shell** — Remote code execution through logging library dependency (CVE-2021-44228)
- [x] **6.10 Case Study: Equifax** — Unpatched dependency exploitation at enterprise scale (CVE-2017-5638)

## Tier 7 — Detection & Response

*Find it, triage it, fix it.*

- [x] **7.1 Detection Rules** — Writing signatures and heuristics for supply chain attacks
- [x] **7.2 Incident Triage** — Rapid scoping and impact assessment for package compromises
- [x] **7.3 IR Playbook** — Step-by-step incident response for supply chain breaches
- [x] **7.4 Tool Evaluation** — Assessing SCA, SAST, and supply chain security tools
- [x] **7.5 Threat Modeling** — Mapping supply chain threats with structured methodologies

## Tier 8 — Organizational

*Policy, compliance, and program building.*

- [x] **8.1 SLSA Deep Dive** — Implementing SLSA levels in real build systems
- [x] **8.2 SSDF & NIST** — Applying NIST SP 800-218 Secure Software Development Framework
- [x] **8.3 Executive Order 14028** — Understanding federal supply chain security requirements
- [x] **8.4 Vendor Assessment** — Evaluating third-party software supply chain practices
- [x] **8.5 Building a Program** — Standing up an organizational supply chain security program
- [x] **8.6 SCVS Assessment** — Applying the Software Component Verification Standard

## Tier 9 — Cloud Supply Chain

*Supply chain attacks in cloud-native environments.*

- [x] **9.1 Cloud Marketplace Poisoning** — Publishing malicious listings in cloud marketplaces
- [x] **9.2 Serverless Supply Chain** — Attacking serverless function dependencies and layers
- [x] **9.3 Cloud CI/CD Attacks** — Exploiting cloud-native CI/CD services and trust boundaries
- [x] **9.4 IAM Chain Abuse** — Leveraging IAM role chains to escalate through supply chain trust

---

**63 / 63 labs complete** — Deployment status below.

| Tier | Topic | Labs | Content | Helm Enabled | CI Tested |
|------|-------|------|---------|-------------|----------|
| 0 | Foundations | 5 | ✅ Complete | ✅ Enabled | ✅ |
| 1 | Package Security | 6 | ✅ Complete | ✅ Enabled | ✅ |
| 2 | Build & CI/CD | 9 | ✅ Complete | ✅ Enabled | ✅ |
| 3 | Container Security | 6 | ✅ Complete | ✅ Enabled | ✅ |
| 4 | Artifact Integrity | 7 | ✅ Complete | ✅ Enabled | ✅ |
| 5 | IaC Supply Chain | 5 | ✅ Complete | ✅ Enabled | ✅ |
| 6 | Advanced & Emerging | 10 | ✅ Complete | ✅ Enabled | ✅ |
| 7 | Detection & Response | 5 | ✅ Complete | ✅ Enabled | ✅ |
| 8 | Organizational | 6 | ✅ Complete | ✅ Enabled | ✅ |
| 9 | Cloud Supply Chain | 4 | ✅ Complete | ✅ Enabled | ✅ |

### What "Deployed" Means

All 63 labs have full content: guide documentation, `lab.yml`, `verify.sh`, and progressive hints. **Deployed** means the tier's infrastructure is wired into the Helm chart, the `setup-labs.sh` seeder populates its registries, and the CI pipeline tests it end-to-end.

---

## Platform Roadmap

Infrastructure and quality improvements driven by professional feedback from SOC analysts, security engineers, DevSecOps, DevOps, and penetration testers.

### Deployment

- [x] **Enable Tier 2-9 in Helm** — Add tier feature flags, seeder phases, and Helm templates for all remaining tiers
- [x] **Add Tier 9 flag to values.yaml** — Tier 9 has no Helm feature flag yet
- [x] **CI coverage for Tiers 2-9** — Extend `test-labs.yml` to deploy and verify all tiers

### Detection Engineering

- ~[ ] **Log pipeline** — Loki + Grafana in the cluster so learners can query real attack-generated logs and test detection rules against live data~ (WONTFIX: Removed to avoid scope creep)
- [x] **Sample alert JSON** — Raw log events that each detection rule would match, so learners can see exactly what triggers an alert
- [x] **False positive analysis** — Known false positives and tuning guidance for every detection rule

### Developer Experience

- [x] **Idempotent start.sh** — Graceful failure handling, port-forward cleanup, and safe re-runs
- [x] **Makefile** — Structured lifecycle targets: `build`, `deploy`, `teardown`, `logs`, `shell`, `test`
- [x] **Docker Compose mode** — Alternative for teams without Kubernetes experience or resources
- [ ] **Minimal mode** — `./start.sh --minimal` for laptops that can't spare 4GB for minikube

### Content Quality

- [x] **Tier 3-4 src content** — Container Security and Artifact Integrity tiers have guide docs and verify scripts but need attack/defend source packages built out
- [x] **Tier 6 src content** — Most Advanced & Emerging labs need source packages (only Log4Shell and Equifax have them)
- [ ] **First Responder Checklists** — Per-lab checklist: what to do in the first 15 minutes if you see this attack in production
- [ ] **Pre-commit hooks** — Ready-to-use `.pre-commit-config.yaml` as a takeaway from each lab
- [ ] **Tool comparison sections** — How would Snyk / Trivy / Dependabot detect each attack?

### Platform Integrity

- [x] **Platform SBOM** — Ship our own software bill of materials (practice what we preach)
- [x] **Image signing** — Sign lab Docker images with Cosign as a meta-example
- [x] **NetworkPolicy templates** — Add Kubernetes NetworkPolicies to the Helm chart
