# Hint 1: NIST SP 800-61 Applied to Supply Chain

The six phases of NIST SP 800-61 Rev 2 map to supply chain incidents like this:

## 1. Preparation
- Maintain an inventory of internal package names (the "namespace registry")
- Configure `--index-url` (not `--extra-index-url`) in all CI pipelines
- Deploy detection rules from Lab 7.1
- Establish secret rotation procedures and document which secrets are used where
- Define roles: who triages, who contains, who communicates

## 2. Detection & Analysis
- Alert source: SIEM rule, EDR alert, manual report, or vulnerability scanner
- Initial questions: What package? What version? How many builds? What timeframe?
- This is Lab 7.2's investigation phase

## 3. Containment
- **Short-term**: Disable affected CI pipelines, block the malicious package version
- **Long-term**: Switch all pipelines from `--extra-index-url` to `--index-url`
- Decision point: do you stop all builds (high disruption) or only affected ones?

## 4. Eradication
- Remove the malicious package from all caches and local registries
- Rebuild all artifacts produced during the compromise window
- Rotate every exposed credential

## 5. Recovery
- Re-enable pipelines with the fix in place
- Monitor for signs that the attacker used stolen credentials
- Verify rebuilt artifacts are clean

## 6. Lessons Learned
- What detection failed? Why did we use `--extra-index-url`?
- What's the policy change to prevent recurrence?
- Update the playbook based on what you learned

Your playbook should have **concrete commands and URLs** for each step, not just "rotate credentials."
