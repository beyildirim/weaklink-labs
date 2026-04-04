For the risk assessment report, structure it as a document you would
present to your procurement committee or security review board.

Key elements:

1. **Executive Summary:** One paragraph. State the vendor, product,
   risk rating, and recommendation (approve/conditional/reject). This
   is what decision-makers read first and sometimes only.

2. **Findings by Category:** For each of the 6 questionnaire sections,
   write 2-3 sentences describing what you found. Be specific: "The
   vendor provides CycloneDX SBOMs with each release" is better than
   "SBOM practices are adequate."

3. **Red Flags:** List anything that is a dealbreaker or requires
   immediate attention. Examples: no vulnerability disclosure process,
   artifacts not signed, known vulnerabilities unpatched for 6+ months.

4. **Recommendations:** Split into "required before approval" (vendor
   must fix these) and "recommended improvements" (would be nice).
   Each recommendation should be specific and actionable.

5. **Monitoring Plan:** How will you reassess this vendor? Quarterly
   questionnaire? Annual audit? Continuous SBOM monitoring?

The risk rating should directly follow from the overall questionnaire
score using the scoring table.
