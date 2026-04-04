For the SBOM, start from the template in `src/sample-sbom.json` and
replace the placeholder values with real data:

1. Use a real tool to generate the base SBOM:
   ```
   syft . -o cyclonedx-json > sample-sbom.json
   # or
   cdxgen -o sample-sbom.json
   ```

2. Verify the SBOM has:
   - `bomFormat`: "CycloneDX"
   - `specVersion`: "1.5" (or later)
   - `metadata.component`: the main application
   - `components[]`: each dependency with name, version, purl
   - `dependencies[]`: the dependency tree

For the VEX document, start from `src/sample-vex.json`:

1. Pick 2-3 real CVEs from a vulnerability scan of the sample app
2. For each, determine the correct status:
   - `not_affected`: the vulnerable code path is not used
   - `affected`: you are vulnerable and need to patch
   - `under_investigation`: you have not yet determined impact
   - `fixed`: a fix has been applied
3. Provide a justification for `not_affected` entries

The combination of SBOM + VEX is what federal customers need to assess
their risk from your software.
