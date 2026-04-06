# Supply Chain Security Program: Implementation Plan

## Organization Profile

| Field | Value |
|-------|-------|
| Organization | WeakLink Corp (sample) |
| Total Employees | 500 |
| Engineering / Developers | 200 |
| Technology Stack | Cloud-native (Kubernetes, containers, CI/CD, microservices) |
| Current Maturity | [Assess during Lab 8.5] |

---

## Pillar 1: Governance

### Objective
Establish ownership, policies, and standards for supply chain security.

#### 30 Days
| Action | Owner | Deliverable |
|--------|-------|-------------|
| Appoint a Supply Chain Security Lead | CISO | Named individual with clear mandate |
| Draft supply chain security policy | Security Lead | Policy document covering dependency intake, build integrity, artifact management |
| Define RACI matrix for supply chain responsibilities | Security Lead | RACI chart across Eng, Security, DevOps, Procurement |

#### 90 Days
| Action | Owner | Deliverable |
|--------|-------|-------------|
| Publish and socialize the policy | Security Lead | Policy in internal wiki, all-hands presentation |
| Establish a Supply Chain Security Working Group | Security Lead | Bi-weekly meeting, cross-functional membership |
| Define vendor security requirements | Procurement + Security | Vendor assessment questionnaire (see Lab 8.4) |

#### 6 Months
| Action | Owner | Deliverable |
|--------|-------|-------------|
| Integrate supply chain requirements into procurement process | Procurement | Updated procurement checklist |
| Conduct first policy review cycle | Working Group | Updated policy based on lessons learned |

#### 1 Year
| Action | Owner | Deliverable |
|--------|-------|-------------|
| Achieve SSDF attestation readiness | Security Lead | Completed SSDF self-attestation form |
| Annual policy review and update | Working Group | Revised policy v2.0 |

---

## Pillar 2: Tooling

### Objective
Deploy automated tools for dependency scanning, SBOM generation, artifact signing, and provenance.

#### 30 Days
| Action | Owner | Deliverable |
|--------|-------|-------------|
| Deploy dependency vulnerability scanning in CI/CD | DevOps | Scanner running on all repositories (e.g., Trivy, Grype) |
| Enable lockfile enforcement | DevOps | CI check that fails builds without lockfiles |
| Inventory current toolchain | DevOps | Spreadsheet of all build tools, registries, CI systems |

#### 90 Days
| Action | Owner | Deliverable |
|--------|-------|-------------|
| Automate SBOM generation for all releases | DevOps | CycloneDX or SPDX SBOM generated in CI/CD |
| Implement artifact signing | DevOps | All container images and release artifacts signed (cosign/sigstore) |
| Deploy private package registry/proxy | DevOps | Artifactory, Nexus, or similar for npm/pip/Go modules |

#### 6 Months
| Action | Owner | Deliverable |
|--------|-------|-------------|
| Generate SLSA Level 2 provenance for all CI builds | DevOps | Provenance attached to all release artifacts |
| Deploy admission controller for signed images | DevOps + Platform | Only signed images deploy to production |
| Implement SBOM-based license compliance checking | Legal + DevOps | Automated license audit in pipeline |

#### 1 Year
| Action | Owner | Deliverable |
|--------|-------|-------------|
| Achieve SLSA Level 3 for critical services | DevOps | Hardened, isolated build environments with unforgeable provenance |
| Deploy VEX generation capability | Security | Automated VEX documents for each release |

---

## Pillar 3: Training

### Objective
Ensure all developers understand supply chain risks and know how to build securely.

#### 30 Days
| Action | Owner | Deliverable |
|--------|-------|-------------|
| Identify training platform/content | Security Lead | Evaluation of WeakLink Labs, SANS, or similar |
| Run a pilot lab session with one team | Security Lead | Feedback from pilot group |

#### 90 Days
| Action | Owner | Deliverable |
|--------|-------|-------------|
| Roll out Tier 0-2 labs to all developers | Security Lead | 80% completion rate target |
| Publish internal "Supply Chain Security 101" guide | Security Lead | Internal documentation |

#### 6 Months
| Action | Owner | Deliverable |
|--------|-------|-------------|
| Roll out Tier 3-5 labs to all developers | Security Lead | Advanced topics covered |
| Conduct a tabletop supply chain incident exercise | Security Lead + IR | Completed exercise with findings |

#### 1 Year
| Action | Owner | Deliverable |
|--------|-------|-------------|
| Integrate supply chain security into onboarding | HR + Security | New hire training includes supply chain module |
| Annual refresher training | Security Lead | Updated content, mandatory completion |

---

## Pillar 4: Monitoring

### Objective
Maintain continuous visibility into dependency risk, build integrity, and anomalies.

#### 30 Days
| Action | Owner | Deliverable |
|--------|-------|-------------|
| Establish a dependency vulnerability dashboard | DevOps | Dashboard showing open vulns across all repos |
| Define SLAs for vulnerability remediation | Security Lead | Critical: 48h, High: 7d, Medium: 30d, Low: 90d |

#### 90 Days
| Action | Owner | Deliverable |
|--------|-------|-------------|
| Monitor for dependency confusion indicators | SOC | Alert rules for public registry access from build infra |
| Track SBOM drift between releases | DevOps | Automated diff showing new/removed/changed components |

#### 6 Months
| Action | Owner | Deliverable |
|--------|-------|-------------|
| Integrate supply chain signals into SIEM | SOC | Correlated alerts for supply chain anomalies |
| Implement build provenance verification in deployment | Platform | Provenance checked before deployment to production |

#### 1 Year
| Action | Owner | Deliverable |
|--------|-------|-------------|
| Publish quarterly supply chain risk report | Security Lead | Executive-ready report with trends and metrics |
| Automate compliance posture monitoring | Security Lead | Dashboard showing EO 14028, SSDF, SLSA status |

---

## Pillar 5: Incident Response

### Objective
Be prepared to detect, contain, and recover from supply chain-specific incidents.

#### 30 Days
| Action | Owner | Deliverable |
|--------|-------|-------------|
| Add supply chain scenarios to IR playbook | IR Team | At least 3 supply chain incident scenarios documented |
| Identify blast radius assessment process | IR Team | Process to determine which systems use a compromised component |

#### 90 Days
| Action | Owner | Deliverable |
|--------|-------|-------------|
| Conduct tabletop exercise (compromised dependency scenario) | IR Team | Exercise report with gaps identified |
| Establish communication templates for supply chain incidents | IR Team + Comms | Internal and external notification templates |

#### 6 Months
| Action | Owner | Deliverable |
|--------|-------|-------------|
| Automate blast radius analysis using SBOMs | IR Team + DevOps | Given a CVE, automatically identify all affected services |
| Test incident notification timeline (EO 14028 compliance) | IR Team | Verified ability to notify within required timeframe |

#### 1 Year
| Action | Owner | Deliverable |
|--------|-------|-------------|
| Conduct full-scale supply chain incident simulation | IR Team | Red team exercise with lessons learned |
| Publish post-incident review process | IR Team | Documented blameless retrospective process |

---

## Pillar 6: Continuous Improvement

### Objective
Track program maturity, measure effectiveness, and iterate.

#### Metrics to Track

| Metric | Baseline | 90-Day Target | 6-Month Target | 1-Year Target |
|--------|----------|---------------|----------------|---------------|
| % of repos with dependency scanning | | | | 100% |
| % of releases with SBOMs | | | | 100% |
| % of artifacts signed | | | | 100% |
| Mean time to remediate critical vulns | | | | < 48 hours |
| Developer training completion rate | | | | > 90% |
| SLSA level for critical services | | | | Level 3 |
| Vendor assessment completion rate | | | | 100% |
| SSDF practice coverage | | | | > 90% |

#### Review Cadence

| Activity | Frequency | Participants |
|----------|-----------|-------------|
| Supply Chain Working Group meeting | Bi-weekly | Security, Eng, DevOps, Procurement |
| Metrics review | Monthly | Security Lead, Engineering Leads |
| Executive briefing | Quarterly | CISO, CTO, VP Engineering |
| Full program review | Annually | All stakeholders |
| External maturity assessment | Annually | Third-party assessor |

---

## Budget Estimate

| Category | Year 1 | Ongoing (Annual) | Notes |
|----------|--------|------------------|-------|
| Tooling (scanners, signing, registry) | $50,000 - $150,000 | $30,000 - $80,000 | Depends on existing tooling |
| Headcount (1 FTE Supply Chain Security Lead) | $150,000 - $200,000 | $150,000 - $200,000 | Can be partial FTE initially |
| Training platform and content | $10,000 - $30,000 | $5,000 - $15,000 | |
| External audit / assessment | $20,000 - $50,000 | $20,000 - $50,000 | Annual |
| **Total** | **$230,000 - $430,000** | **$205,000 - $345,000** | |

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Developer resistance to new tooling | High | Medium | Start with non-blocking checks, provide training, show value |
| Tooling integration issues with existing CI/CD | Medium | High | Allocate DevOps time, pilot with one team first |
| Executive sponsorship fades | Medium | Critical | Deliver quick wins in 30 days, publish metrics monthly |
| Regulatory landscape changes | Medium | Medium | Assign someone to track CISA/NIST updates, attend working groups |
| Vendor non-compliance | High | Medium | Phase in requirements, provide assessment timeline |
