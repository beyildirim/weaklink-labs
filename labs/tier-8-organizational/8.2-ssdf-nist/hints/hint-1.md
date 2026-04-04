When mapping WeakLink Labs defenses to SSDF practices, think about which
labs addressed which practice areas:

**PO (Prepare Organization):**
- Lab 0.x (Foundations) maps to PO.4 (training/resources)
- Lockfile enforcement maps to PO.5 (security checks)

**PS (Protect Software):**
- Lab 4.3 (signing) maps to PS.1 (protect code from tampering)
- Lab 4.4 (attestation) maps to PS.3 (verify integrity and provenance)

**PW (Produce Well-Secured Software):**
- Lab 1.x (dependency security) maps to PW.7 (acquire secure components)
- Lab 4.1/4.2 (SBOM) maps to PW.8 (maintain SBOM)
- Lab 2.x (CI/CD security) maps to PW.6 (secure build tools)

**RV (Respond to Vulnerabilities):**
- Dependency scanning maps to RV.1 (identify vulnerabilities)
- This area often has the most gaps if you have not built response processes

The biggest gaps are usually in PO (governance) and RV (vulnerability response)
because they require organizational processes, not just technical controls.
