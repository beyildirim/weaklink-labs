For the framework overlap analysis, use the mapping reference in
`src/scvs-slsa-ssdf-mapping.md` as your starting point, then customize
it based on your assessment findings.

Key overlap patterns to look for:

1. **SCVS V3 (Build Environment) maps heavily to SLSA**: SLSA's entire
   Build track (Levels 1-3) corresponds to SCVS V3 controls. If you
   completed Lab 8.1 (SLSA), your V3 assessment should be consistent.

2. **SCVS V2 (SBOM) maps to SSDF RV.3.3**: The SBOM generation and
   distribution requirements overlap directly. If you completed Lab 8.2
   (SSDF), your V2 assessment and SSDF RV.3.3 status should match.

3. **SCVS V4 (Package Management) maps to SSDF PW.4.1 and PW.4.4**: The
   dependency controls you assessed in SSDF map directly to SCVS V4.

4. **EO 14028 ties them together**: The Executive Order requires SBOM
   delivery (SCVS V2, SSDF RV.3.3), secure development practices (SSDF
   PO/PS/PW), and build integrity (SLSA, SCVS V3). One control can
   satisfy multiple frameworks simultaneously.

For the remediation roadmap, prioritize controls that satisfy multiple
frameworks at once. These give the best return on investment. For
example, implementing SBOM generation satisfies SCVS V2, SSDF RV.3.3,
and EO 14028 requirements simultaneously.
