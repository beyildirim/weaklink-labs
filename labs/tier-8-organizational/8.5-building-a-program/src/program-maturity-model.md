# Supply Chain Security Program Maturity Model

Use this model to assess your organization's current maturity and set targets.

---

## Maturity Levels

| Level | Name | Description |
|-------|------|-------------|
| **1** | Initial | Ad-hoc. Individual developers may follow some practices, but nothing is standardized or enforced. |
| **2** | Developing | Basic controls are in place. Dependency scanning exists but may not cover all repos. SBOMs are generated for some projects. |
| **3** | Defined | Documented policies and standards exist. Tooling is deployed organization-wide. Training is provided to all developers. |
| **4** | Managed | Metrics are tracked. Compliance is measured. Incident response includes supply chain scenarios. Vendors are assessed. |
| **5** | Optimizing | Continuous improvement based on data. Proactive threat intelligence. Industry-leading practices. Contributing back to standards. |

---

## Assessment Matrix

Rate your organization 1-5 on each capability:

| Capability | Level 1 | Level 2 | Level 3 | Level 4 | Level 5 | Current |
|-----------|---------|---------|---------|---------|---------|---------|
| **Dependency scanning** | No scanning | Some repos scanned | All repos scanned in CI | SLAs enforced, metrics tracked | Proactive research, zero-day response | |
| **SBOM generation** | No SBOMs | Some projects have SBOMs | All releases include SBOMs | SBOMs distributed to consumers, drift tracked | SBOMs used for automated compliance and incident response | |
| **Artifact signing** | No signing | Critical artifacts signed | All artifacts signed | Signature verification enforced at deployment | Keyless signing with transparency logs | |
| **Build provenance** | No provenance | Some builds generate provenance | SLSA L1-2 for all builds | SLSA L3 for critical services | SLSA L4, hermetic reproducible builds | |
| **Vulnerability response** | Ad-hoc patching | Disclosure policy exists | SLAs defined and tracked | VEX documents published, automated triage | Proactive, SBOMs enable instant blast radius analysis | |
| **Developer training** | No training | Awareness presentations | Hands-on labs for all devs | Training integrated into onboarding, annual refresh | Developers contribute to security tooling and standards | |
| **Vendor management** | No vendor assessment | Basic security questions | Formal questionnaire process | Ongoing monitoring, re-assessment cadence | Collaborative improvement with vendors | |
| **Governance** | No policy | Draft policy exists | Published and socialized policy | Regular review cycle, working group active | Industry participation, standards contribution | |
| **Incident readiness** | No supply chain playbooks | Basic playbook exists | Tabletop exercises conducted | Automated blast radius analysis | Full simulations, sub-24h response demonstrated | |
| **Monitoring** | No monitoring | Basic vuln dashboards | Supply chain signals in SIEM | Correlated alerting, anomaly detection | Predictive analytics, threat intelligence integration | |

---

## Scoring

**Total Score:** ___ / 50

| Score Range | Overall Maturity |
|-------------|-----------------|
| 10-15 | Level 1: Initial |
| 16-25 | Level 2: Developing |
| 26-35 | Level 3: Defined |
| 36-45 | Level 4: Managed |
| 46-50 | Level 5: Optimizing |

**Current Overall Maturity:** Level ___

**Target Maturity (1 year):** Level ___
