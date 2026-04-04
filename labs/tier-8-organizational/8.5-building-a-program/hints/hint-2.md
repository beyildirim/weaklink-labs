The implementation plan is the detailed counterpart to the executive briefing.
Use the template in `src/implementation-plan.md` as your starting point.

For each pillar and each time horizon, make the actions specific:

**Bad:** "Improve dependency management"
**Good:** "Deploy Trivy in GitHub Actions for all 47 repositories. Configure
to fail builds on critical/high CVEs. DevOps team owns integration, due
April 30."

For the maturity model (`src/program-maturity-model.md`):
- Assess where the sample organization stands TODAY on each capability
- Most organizations without a program start at Level 1-2
- Set a realistic 1-year target (usually Level 3-4, not Level 5)
- Level 5 requires years of investment; do not plan for it in year 1

For budget, use realistic ranges:
- Open-source tooling (Trivy, Syft, cosign): $0 for tools, cost is in
  engineering time to integrate (~0.5 FTE for 3 months)
- Commercial tooling (Snyk, Sonatype, etc.): $30-150K/year depending
  on developer count
- Dedicated headcount: $150-200K/year for a supply chain security lead
- Training: $10-30K/year for platform + content
- External audit: $20-50K per engagement

The total year-1 investment for a 200-developer org is typically $230-430K.
Frame it against the cost of a single supply chain incident ($4-10M average).
