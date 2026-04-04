Treat the WeakLink sample application as if it were a product from an
external vendor that your organization is evaluating for procurement.

For each section of the questionnaire, imagine you are the procurement
security reviewer:

- **SBOM:** Did the "vendor" provide an SBOM with the release? Is it
  in a standard format? Does it include transitive dependencies?
- **Build provenance:** Can you verify where and how the artifact was
  built? Is there a signature you can check?
- **Dependency management:** Does the project use lockfiles? Is there
  evidence of dependency scanning?
- **Vulnerability response:** Is there a SECURITY.md or security.txt?
  What is their response track record?

Score honestly. A score of 0 means "the vendor provided nothing."
A score of 3 means "documented, implemented, and I can see the evidence."

Red flags to watch for:
- No SBOM provided at all
- No build provenance or signing
- No public vulnerability disclosure process
- Dependencies not pinned or scanned
- "We handle security internally" with no evidence
