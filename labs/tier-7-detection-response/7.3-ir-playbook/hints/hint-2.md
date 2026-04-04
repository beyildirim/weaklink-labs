# Hint 2: Decision Trees and Post-Incident Template

## Decision Tree Structure

Your playbook should include decision points. Here's a skeleton:

```
ALERT: Suspicious package version detected in CI
  |
  v
Is the package name in our internal namespace registry?
  |-- NO --> Check for typosquatting (edit distance < 3 from known package)
  |           |-- YES --> Escalate as potential typosquatting, SEV-2
  |           |-- NO  --> Likely false positive, document and close
  |-- YES --> DEPENDENCY CONFUSION CONFIRMED
              |
              v
        Did the build complete successfully?
          |-- YES --> Artifacts may be compromised. Continue to containment.
          |-- NO  --> Blast radius limited. Still rotate secrets.
              |
              v
        Were secrets in the CI environment?
          |-- YES --> SEV-1 CRITICAL. Full secret rotation required.
          |-- NO  --> SEV-2 HIGH. Package-level containment only.
```

## Post-Incident Report Template Sections

Your template should include these sections with placeholder text:

1. **Incident ID** and date
2. **Executive Summary** (what, when, how, impact)
3. **Detection** (how was it found, what fired the alert)
4. **Timeline** (chronological event list with UTC timestamps)
5. **Root Cause Analysis** (why did this happen, what allowed it)
6. **Impact Assessment** (systems affected, data exposed, business impact)
7. **Response Actions Taken** (what was done, by whom, when)
8. **Gaps Identified** (what the playbook missed, what was slow)
9. **Remediation & Follow-Up** (action items with owners and deadlines)
10. **Lessons Learned** (process improvements, detection improvements, training needs)

Keep each section short. The post-incident report is a reference document, not a novel.
