Start by reviewing the SLSA level reference in `src/slsa-level-reference.md`.
For each level, ask yourself: does the WeakLink sample application meet
**every** requirement at that level?

Key questions to guide your assessment:

- Level 1: Is there any build provenance at all? Is the build scripted?
- Level 2: Do builds run on a hosted platform? Is provenance signed?
- Level 3: Are builds isolated? Can a tenant forge provenance?
- Level 4: Are builds hermetic? Is there two-party review?

Most projects that have not specifically invested in SLSA compliance land
at Level 0 or Level 1. Be honest in your assessment. The value of the
exercise is in identifying the gaps, not in claiming a high level.
