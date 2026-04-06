# WeakLink Labs Content Quality Review

Reviewed: 2026-04-06. Focus: teaching effectiveness, not command execution.

## The Core Problem

The platform's biggest teaching weakness is the gap between conceptual understanding and active discovery. In the strongest labs (1.2, 2.6, 3.5, 4.6), the student does something, observes a specific outcome, and the "why" is revealed by what they just saw. In the weakest labs (7.2, 7.5, 8.5, 6.3), the student reads a completed analysis and runs a verify command.

---

## Copy-Paste Labs (student doesn't understand why)

- **2.4** Secret Exfiltration: Student exports fake secrets themselves then echoes them. DNS exfil step says "Would execute: dig ..." but never fires. Student sees concept described, not demonstrated.
- **6.3** Firmware: Requires binwalk/uefi-firmware-parser on binary blobs. No explanation of DXE drivers, PEI volumes, NVRAM before commands run. Student extracts structures with no mental model.
- **5.5** Admission Controller Bypass 2+3: Student applies YAML manifests without seeing them first. No prompt to understand what the CRD creates or why CronJob patching bypasses admission.
- **7.2** Incident Triage: All data pre-filled in the guide. Student reads proxy logs, setup.py code, blast radius tables instead of querying real data.

## Contrived Scenarios

- **2.4** Secret Exfiltration: Student is both attacker injecting the secret AND attacker reading it. Breaks immersion.
- **6.3** Firmware: Simulated .bin files, not real UEFI. verify_update.sh always passes. Feels fake compared to labs with real pip/docker/npm ecosystems.
- **8.4** Vendor Assessment: Evidence gathering queries /app/ directory (your own app). Real vendor assessment would query vendor's public GitHub, docs, release artifacts. Collapses distinction between "I am the vendor" and "I am assessing a vendor."

## Passive Reading (student reads, doesn't do)

- **7.2** Incident Triage Phase 1-3: All incident data given verbatim. Student could skip every step and pass verification by reading.
- **7.5** Threat Modeling Phase 3: STRIDE tables for all trust boundaries fully completed. No "apply STRIDE yourself before reading the answer" moment.
- **8.5** Building a Program: Every section pre-filled. Student reads a complete program document with a verify button attached.
- **8.1** SLSA Deep Dive Phase 2: Assessment table already filled in ("Current SLSA Level: 0") before student can form their own assessment.
- **6.5-6.10** Case Studies: Mostly reading. Cannot reproduce SolarWinds SUNBURST or Codecov bash modification. Gap between reading and doing widest here.

## Confusing Explanations

- **3.5** Layer Injection Step 2-3: No explanation that crane blob upload must happen before manifest patch. Student who misses this gets confusing registry errors.
- **4.6** Attestation Forgery Step 5: "accepts any valid signature" is technically wrong. The vulnerability is policy misconfiguration, not accepting any signature.
- **2.7** Build Cache Poisoning: Copies .whl to two different cache locations without explaining which one CI reads from or why both are needed.
- **5.3** Terraform Modules Phase 3: Defense overwrites main.tf but malicious null_resource in modules/ still exists. No intermediate check between edit and verify.
- **2.8** Workflow Run Attacks: Break depends on workflow_run trigger which is GitHub Actions behavior. Lab uses Gitea. Student told to "understand" how it works but never sees it fire.

## Missing "So What?"

- **1.5** Manifest Confusion: Defense says "use npm ci" but doesn't explain npm ci is only safe if lockfile was generated trustworthily. Loop never closed.
- **5.5** Admission Controller: Ends without addressing that CoreDNS, CNI plugins legitimately need kube-system exemptions. No practical answer for "what do I actually exempt?"
- **6.4** Multi-Vector Attack: "Use ignore-scripts" glosses over the fact it breaks esbuild, sharp, husky, native bindings. Not actionable as written.
- **9.4** IAM Chain Abuse: Recommends source IP restrictions but doesn't address ephemeral CI runner IPs. OIDC federation (Fix 3) is the right answer but Fixes 1-2 presented as simpler alternatives without noting their deployment friction.
- **3.4, 3.6** No named real-world incidents. Feel academic compared to labs with Birsan, xz-utils, Codecov anchors.

## Actually Good

- **1.2** Dependency Confusion: Best lab. Realistic developer action (loosening a pin), clear aha moment, actionable detect phase, real-world anchor ($130K bounty).
- **2.6** Actions Injection: Best pedagogical table (attacker-controlled vs safe contexts). Explicitly contrasts with prior lab. Side-by-side before/after fix.
- **3.5** Layer Injection: Baseline digest recording before attack is a genuine teaching moment. "If nobody recorded originals, nobody notices" lands because student generated the baseline.
- **6.5** xz-utils Case Study: diff command between git checkout and release tarball is the exact right exercise. Three-layer concealment summary is clearest in the platform.
- **9.4** IAM Chain Abuse: CloudTrail comparison table with concrete numeric thresholds is most operationally useful detection table in the platform.
- **4.6** Attestation Forgery: Manual forgery forces understanding. cosign verify succeeding with attacker key is a genuine aha. Indicator table is operationally specific.
- **1.4** Lockfile Injection: "chore: update flask-utils" PR framing is exactly right. Git diff forces discovery of hash swap.
- **7.2** Incident Triage (opening only): "It is 14:47 on a Tuesday" is the best opening hook. SEV classification table is directly reusable.

---

## Action Items

### High Priority (fix the passive labs)
1. **7.2, 7.5, 8.1, 8.5**: Remove pre-filled answers. Give the student raw data and let them build the analysis. Show the answer AFTER they attempt it.
2. **6.5-6.10 Case Studies**: Add at least one interactive discovery step per case study (like 6.5's diff command). Reading-only sections should be minority, not majority.

### Medium Priority (close the gaps)
3. **2.4**: Use real CI secrets from Gitea instead of manually exported fakes. The DNS exfil should actually execute.
4. **6.3**: Either install binwalk or redesign around plaintext-simulated firmware with clear framing that it's simulated.
5. **1.5**: Add a paragraph explaining when npm ci's lockfile itself becomes untrustworthy.
6. **5.5**: Add a "practical exemptions" section covering CoreDNS/CNI/cert-manager.
7. **6.4**: Replace "just use ignore-scripts" with a nuanced approach (allowlisted scripts, sandboxed installs).

### Low Priority (polish)
8. **3.5, 2.7, 5.3**: Add explanatory text before the confusing steps.
9. **4.6**: Fix "accepts any valid signature" wording.
10. **2.8**: Acknowledge that workflow_run cannot fire in Gitea; frame as "in GitHub Actions, this would trigger..."
