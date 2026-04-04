The three pillars of EO 14028 compliance for software vendors are:

1. **SBOM (Section 4e):** You must produce a machine-readable SBOM
   in SPDX or CycloneDX format. It must include: component names,
   versions, suppliers, dependency relationships, and unique identifiers
   (purl or CPE). The SBOM must be updated with each release.

2. **Vulnerability Disclosure (Section 2):** You need a public-facing
   mechanism for reporting vulnerabilities. The minimum is a
   `security.txt` file or a SECURITY.md in your repository. You need
   a defined SLA for acknowledgment and response.

3. **Incident Notification (Section 3):** You must be able to notify
   federal customers of security incidents within the required timeline.
   This means having an incident response plan that specifically covers
   the federal notification pathway.

When assessing the sample application, check whether each of these
three pillars is addressed. Most projects have partial SBOM coverage
but lack a formal disclosure policy or incident notification process.
