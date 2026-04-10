# Lab 7.3: Incident Response Playbook

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../investigate/" class="phase-step done">Investigate</a>
  <span class="phase-arrow">›</span>
  <a href="../validate/" class="phase-step done">Validate</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Improve</span>
</div>

**Goal:** Stress-test the playbook with edge cases.

## Scenario A: The attacker published the package 6 months ago

The compromise window is not 3 hours but 6 months. Every build for 6 months is potentially compromised. Secrets may have been rotated since, but the attacker may have used the old ones. Cloud provider logs may not retain beyond 90 days.

## Scenario B: The attacker used the stolen GH_TOKEN to add a backdoor

During the 3-hour window, the attacker pushed a commit adding a subtle backdoor (hardcoded admin credentials). This is a secondary compromise that extends beyond CI.

## Scenario C: The malicious package does not exfiltrate. it backdoors

Instead of exfiltrating secrets, the package modifies its `authenticate()` function to accept a hardcoded password. No C2 traffic, no EDR alerts. Detection requires code review or runtime authentication anomaly monitoring.


## What You Learned

- A playbook turns ad-hoc response into a repeatable process. Without one, quality depends entirely on who is on-call.
- Decision trees reduce triage time. Clear classification prevents analysts from under- or over-escalating.
- Tabletop exercises reveal gaps. Edge cases like long compromise windows, secondary compromise, and non-exfiltrating malware break simple playbooks.

## Further Reading

- [NIST SP 800-61 Rev. 2: Computer Security Incident Handling Guide](https://csrc.nist.gov/publications/detail/sp/800-61/rev-2/final)
- [SANS Incident Handler's Handbook](https://www.sans.org/white-papers/33901/)
- [Google SRE Book: Managing Incidents](https://sre.google/sre-book/managing-incidents/)
