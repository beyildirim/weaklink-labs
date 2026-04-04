Start by filling in the assessment worksheet (`src/scvs-worksheet.md`) one
category at a time. For each category, work through the Level 1 controls
first before moving to Level 2 and 3.

Key questions to guide your assessment:

- **V1 (Inventory):** Does the project maintain a list of all components?
  Is it automated or manual? Does it include transitive dependencies?
- **V2 (SBOM):** Is there an SBOM? What format? Does it include all
  required fields (supplier, version, license, hashes)?
- **V3 (Build Environment):** Is the build reproducible? Are build tools
  version-pinned? Is the build environment ephemeral?
- **V4 (Package Management):** Are dependencies pinned to exact versions?
  Are hashes verified? Is there a process for reviewing new dependencies?
- **V5 (Component Analysis):** Is there automated vulnerability scanning?
  How quickly are vulnerabilities remediated? Is there a known-good baseline?
- **V6 (Pedigree and Provenance):** Can you trace each component back to
  its source? Is there signed provenance? Are upstream maintainers vetted?

Most projects that have not specifically invested in SCVS will meet some
Level 1 controls but very few Level 2 or 3 controls. Be honest -- the
value is in identifying gaps, not claiming maturity.
