# WeakLink Labs Content Audit

Audited: 2026-04-05. All 63 labs across 10 tiers.

## Critical Issues

### 1. Lab 7.1 Phase 3 is completely empty
Five rule headers with zero content. The core exercise (writing detection rules) is missing. Students hit a wall.

### 2. Tier 9 labs (9.2, 9.3, 9.4) are walkthroughs, not hands-on
AWS CLI commands reference fake account IDs. No simulated environment. Students read, never execute. Only 9.1 has real docker commands.

### 3. Factual error in Lab 6.9
MITRE ATT&CK mapping cites T1059.007 (JavaScript) for Log4Shell. Log4Shell exploits Java class loading via JNDI, not JavaScript.

---

## Systematic Issues (pattern across multiple labs)

### Dead-end questions (no answer mechanism)
| Lab | Text |
|-----|------|
| 0.1 | "What was the first thing added? Check the oldest commit message." |
| 0.1 | "What files changed? How many lines added vs removed?" |
| 3.1 | Checkpoint: "What is a whiteout file?" (term never defined in the lab) |
| 3.2 | Checkpoint: "Would imagePullPolicy: IfNotPresent have prevented this?" (never discussed) |
| 3.3 | Checkpoint: "Why did trivy not flag the backdoor?" (requires scanner internals knowledge not taught) |
| 3.4 | Checkpoint: "How does this differ from pip's dependency confusion?" (cross-tier knowledge assumed) |
| 3.5 | Checkpoint: "Why did docker pull not reject the extra layer?" (not explicitly taught) |
| 3.6 | Checkpoint: "Which leaks would trivy catch?" (requires tool knowledge not covered) |
| 4.1 | Checkpoint: 3 questions with no answer mechanism |
| 4.2 | Checkpoint: 3 questions with no answer mechanism |
| 4.3 | Checkpoint: 3 questions with no answer mechanism |

**Decision: Kill all dead-end questions.** If the student completed the steps, they already know.

### Missing intro paragraphs
| Lab | Issue |
|-----|-------|
| 4.1 | Jumps to Attack Flow, no intro |
| 4.2 | Jumps to Attack Flow, no intro |
| 4.3 | Jumps to Attack Flow, no intro |

### Missing real-world incident framing
Labs that explain the concept but cite no real incident, making them feel theoretical:

| Lab | Missing |
|-----|---------|
| 0.5 | No incident cited. Could reference Codecov bash uploader artifact tampering |
| 1.1 | No named incident (dependency confusion in 1.2 covers it, but 1.1 stands alone) |
| 1.6 | No named incident for phantom deps. Could reference event-stream |
| 2.3 | No named incident for indirect PPE |
| 2.7 | No named incident for cache poisoning |
| 2.9 | No named incident for GitLab CI attacks |
| 3.1 | No incident for layer internals |
| 3.2 | No incident for tag mutability |
| 3.4 | No incident for registry confusion |
| 3.5 | No incident for layer injection |
| 3.6 | No incident for multi-stage leaks |
| 4.1 | No incident for SBOM contents |
| 4.2 | No incident for SBOM gaps |
| 4.3 | No incident for signing fundamentals |
| 4.7 | No incident for SBOM tampering |
| 5.4 | No incident for Ansible Galaxy attacks |
| 5.5 | No incident for admission controller bypass |
| 8.6 | No incident for SCVS assessment |

### Unexplained commands (run this with no why)
| Lab | Commands |
|-----|----------|
| 0.1 | `git diff $(git rev-list --max-parents=0 HEAD) HEAD` |
| 0.2, 1.1 | `curl ... \| grep -o 'href="[^"]*"'` (regex not explained) |
| 1.3 | `grep -oP '(?<=href="/simple/)[^/]+'` (Perl regex, harder) |
| 1.6 | `publish-attack` (custom command, zero explanation) |
| 2.4 | `echo "${TOKEN}" \| rev` / `\| base64` / `\| fold -w 10` (masking bypass not explained) |
| 2.5 | Runner filesystem commands with no "what to look for" |
| 2.7 | Cache inspection commands with no context |
| 3.1 | `crane` used without introduction; layer extraction loop unexplained |
| 3.5 | `stat -c %s` vs `stat -f %z` (GNU vs BSD) not explained |
| 6.2 | `cat /app/train_model.py` with no guidance on what to look for |
| 6.3 | Firmware commands with explanation AFTER, not before |
| 8.1 | `grep` commands with no per-command explanation |
| 8.6 | Five `grep` commands with no per-command explanation |
| 9.1 | Six audit commands (`ps aux`, `ss -tlnp`, etc.) with no per-command explanation |

### CI Integration bloat (to be moved to Resources > CI Recipes)
| Lab | Lines | Notes |
|-----|-------|-------|
| 1.3 | 132 | Includes 50-line Python Levenshtein implementation |
| 1.2 | 86 | Two checks (extra-index-url + public name check) |
| 1.1 | 80 | Three separate concerns in one workflow |
| 1.6 | 78 | Two jobs, second one tangential |
| 5.1 | 70 | Complex bash with IFS manipulation |
| 0.3 | 59 | |
| 1.5 | 58 | |
| 5.4 | 55 | Embedded Python in YAML |
| 5.5 | 54 | |
| 0.1 | 55 | |
| 0.2 | 52 | |
| 5.3 | 51 | Duplicates Phase 3 content |
| 3.5 | 50 | Full CI pipeline, not focused check |
| 2.7 | 46 | |
| 2.5 | 45 | |
| 2.9 | 46 | |
| 1.4 | 40 | Plus 17-line duplicate inline in Phase 3 |

Labs WITHOUT CI Integration: all of Tier 6 (case studies), all of Tier 7, all of Tier 8, all of Tier 9, and 4.1-4.3.

### Placeholder paths that break the lab flow
| Lab | Issue |
|-----|-------|
| 3.1 | `<layer-dir>` and `<path-to-backdoor>` placeholders. Student doesn't know what to substitute |
| 4.3 | `<PASTE TRUSTED cosign.pub HERE>` with no scripted solution |
| 4.5 | `<PASTE TRUSTED cosign.pub HERE>` again |
| 4.6 | `<log-entry-uuid>` with no instruction on how to get the UUID |

### Structural inconsistencies
| Lab | Issue |
|-----|-------|
| 0.4 | Missing: Connect to Workstation, Environment table, What You Learned, Further Reading, SOC Relevance. Uses `weaklink check` instead of `weaklink verify`. Uses `???+ shield` (non-standard admonition) |
| 0.5 | Same issues as 0.4. Phase 1 uses `???+ success` instead of `???+ info`. Hardcoded fake hash |
| 0.1 | OWASP link text/URL mismatch |
| 1.4 | Duplicate CI YAML (inline in Phase 3 + collapsed section) |
| 2.9 | Covers 3 attack vectors, Attack 3 has zero hands-on steps |
| 4.4 | SLSA levels table uses outdated v0.1 naming (v1.0 renamed them) |
| 4.6 | `COSIGN_EXPERIMENTAL=1` is deprecated |
| 5.5 | Prerequisite link uses directory path instead of .md file |
| 6.1, 6.3 | Grammar: "loaded. and why" / "applied. and where" (period should be comma) |
| 6.8 | Comparison table uses plaintext instead of markdown table syntax |
| 8.4 | Phase 3 labeled "VALIDATE" instead of "PLAN" (Tier 8 structure) |
| 8.5 | Phase 2 labeled "DESIGN" instead of "ASSESS" (Tier 8 structure) |
| 8.5 | Self-referential: "Complete WeakLink Labs Tier 0-1 for all developers" |
| 8.6 | Dots (`.`) in table cells look like rendering bugs |
| 9.3 | Lowercase "it" after period in intro |

### Missing standard sections (Tiers 8-9)
ALL labs in Tiers 8 and 9 are missing:
- Environment table
- SOC Relevance section
- CI Integration section (intentional for Tier 8 governance labs, notable for Tier 9)

### Passive/non-interactive content
| Lab | Issue |
|-----|-------|
| 7.3 | Presents a completed playbook. Student reads, doesn't create. Tabletop scenarios have no answer key |
| 7.4 | Pre-filled detection coverage matrix. Socket referenced with no way to run it. `deps.dev` API requires internet |
| 7.5 | Zero commands. Entirely reading pre-filled STRIDE tables. TB-2, TB-5, TB-7 counted in totals but never analyzed |
| 8.2 | Coverage gaps presented as given, not discovered |
| 8.5 | Executive briefing template duplicates what student should have produced |

### Double `---` separators (visual artifact)
Labs 5.1, 5.2, 5.3 have consecutive horizontal rules with nothing between them.

---

## Per-Lab Summary

### Tier 0
| Lab | Intro | Dead-end Q | Unexplained Cmds | CI Bloat | Real-world | Other |
|-----|-------|-----------|-------------------|----------|------------|-------|
| 0.1 | yes | 2 questions | 1 (git rev-list) | 55 lines | yes | OWASP link mismatch |
| 0.2 | yes | none | 1 (grep regex) | 52 lines | yes | |
| 0.3 | yes | none | none | 59 lines | yes | Clean |
| 0.4 | yes | none | none | none | yes | Missing 5 standard sections |
| 0.5 | yes | none | none | none | no | Missing sections, fake hash, wrong admonition |

### Tier 1
| Lab | Intro | Dead-end Q | Unexplained Cmds | CI Bloat | Real-world | Other |
|-----|-------|-----------|-------------------|----------|------------|-------|
| 1.1 | yes | none | 1 (grep regex) | 80 lines | partial | Phase 1 includes a mini-attack |
| 1.2 | yes | none | none | 86 lines | excellent | Strongest lab |
| 1.3 | yes | none | 1 (Perl regex) | 132 lines | yes | Largest CI section |
| 1.4 | yes | none | none | 40+17 dup | partial | Duplicate CI inline |
| 1.5 | yes | none | none | 58 lines | excellent | Clean |
| 1.6 | yes | none | 1 (publish-attack) | 78 lines | partial | |

### Tier 2
| Lab | Intro | Dead-end Q | Unexplained Cmds | CI Bloat | Real-world | Other |
|-----|-------|-----------|-------------------|----------|------------|-------|
| 2.1 | yes | none | none | 44 lines | yes | |
| 2.2 | yes | none | none | yes | yes | Clean |
| 2.3 | yes | none | none | yes | partial | |
| 2.4 | yes | none | 3 (masking bypass) | yes | yes | |
| 2.5 | yes | none | 2 (runner inspect) | 45 lines | yes | |
| 2.6 | yes | none | none | yes | excellent | Strongest in tier |
| 2.7 | yes | none | 1 (cache inspect) | 46 lines | partial | |
| 2.8 | yes | none | none | yes | yes | OIDC tangent (30 lines) |
| 2.9 | yes | none | none | 46 lines | partial | Attack 3 has no hands-on |

### Tier 3
| Lab | Intro | Dead-end Q | Unexplained Cmds | CI Bloat | Real-world | Other |
|-----|-------|-----------|-------------------|----------|------------|-------|
| 3.1 | partial | 3 (whiteout undefined) | 2 (crane, layers) | yes | partial | Placeholder paths |
| 3.2 | yes | 3 | none | yes | partial | |
| 3.3 | yes | 3 | none | yes | partial | XZ in Further Reading, not intro |
| 3.4 | yes | 3 (cross-tier assumed) | none | yes | partial | |
| 3.5 | yes | 3 | 1 (stat flags) | 50 lines | partial | |
| 3.6 | yes | 3 | none | yes | partial | |

### Tier 4
| Lab | Intro | Dead-end Q | Unexplained Cmds | CI Bloat | Real-world | Other |
|-----|-------|-----------|-------------------|----------|------------|-------|
| 4.1 | NO | 3 | none | none | missing | |
| 4.2 | NO | 3 | none | none | missing | |
| 4.3 | NO | 3 | none | none | missing | Fragile sed command |
| 4.4 | yes | none | none | 13 lines | partial | Outdated SLSA levels |
| 4.5 | yes | none | none | 31 lines | partial | Placeholder key |
| 4.6 | yes | none | none | 35 lines | partial | Deprecated COSIGN_EXPERIMENTAL |
| 4.7 | yes | none | none | 21 lines | missing | |

### Tier 5
| Lab | Intro | Dead-end Q | Unexplained Cmds | CI Bloat | Real-world | Other |
|-----|-------|-----------|-------------------|----------|------------|-------|
| 5.1 | yes | none | none | 70 lines | partial | Double --- |
| 5.2 | yes | none | none | 40 lines | partial | Double --- |
| 5.3 | yes | none | none | 51 lines | partial | Double ---; hand-wavy edit step |
| 5.4 | yes | none | none | 55 lines | missing | |
| 5.5 | yes | none | none | 54 lines | missing | Broken prerequisite link |

### Tier 6
| Lab | Intro | Dead-end Q | Unexplained Cmds | CI Bloat | Real-world | Other |
|-----|-------|-----------|-------------------|----------|------------|-------|
| 6.1 | yes | none | none | none | yes | Grammar issue |
| 6.2 | yes | none | 1 (cat with no guidance) | none | yes | |
| 6.3 | yes | none | 2 (firmware cmds) | none | excellent | Grammar issue |
| 6.4 | yes | none | none | none | excellent | Placeholder cosign key |
| 6.5 | yes | none | none | none | excellent | Case study (xz-utils) |
| 6.6 | yes | none | none | none | excellent | Case study (SolarWinds) |
| 6.7 | yes | none | none | none | excellent | Case study (Codecov) |
| 6.8 | yes | none | none | none | excellent | Plaintext table formatting |
| 6.9 | yes | none | none | none | excellent | MITRE factual error (JS vs Java) |
| 6.10 | yes | none | none | none | excellent | Non-interactive WAF/YAML blocks |

### Tier 7
| Lab | Intro | Dead-end Q | Unexplained Cmds | CI Bloat | Real-world | Other |
|-----|-------|-----------|-------------------|----------|------------|-------|
| 7.1 | yes | none | none | none | yes | **PHASE 3 IS EMPTY** |
| 7.2 | yes | none | 1 (pip flags) | none | yes | Inline Splunk query |
| 7.3 | yes | none | none | none | yes | Passive: student reads completed playbook |
| 7.4 | yes | none | none | none | yes | Socket not available; deps.dev needs internet |
| 7.5 | yes | none | none | none | yes | Zero commands, entirely passive |

### Tier 8
| Lab | Intro | Dead-end Q | Unexplained Cmds | CI Bloat | Real-world | Other |
|-----|-------|-----------|-------------------|----------|------------|-------|
| 8.1 | yes | none | 2 (grep cmds) | none | partial | Missing: Env table, SOC |
| 8.2 | yes | none | none | none | partial | Meta-lab (labs about labs) |
| 8.3 | yes | none | none | none | yes | ? placeholders (interactive, good) |
| 8.4 | yes | none | 1 (gather evidence) | none | partial | Phase 3 mislabeled VALIDATE |
| 8.5 | yes | none | none | none | partial | Phase 2 mislabeled DESIGN; self-referential |
| 8.6 | yes | none | 2 (grep cmds) | none | missing | Dot formatting bugs |

### Tier 9
| Lab | Intro | Dead-end Q | Unexplained Cmds | CI Bloat | Real-world | Other |
|-----|-------|-----------|-------------------|----------|------------|-------|
| 9.1 | yes | none | 2 (audit cmds) | none | partial | Only tier 9 lab with real hands-on |
| 9.2 | yes | none | 1 (--no-deps) | none | partial | Phase 2 is analysis, not exploitation |
| 9.3 | yes | none | none | none | partial | Commands are conceptual, can't execute |
| 9.4 | yes | none | none | none | partial | Commands are conceptual, can't execute |

---

## Action Items (prioritized)

### P0: Broken content -- DONE
1. ~~Write Phase 3 content for Lab 7.1 (detection rules)~~ FIXED: 5 Sigma rules with validation commands
2. ~~Fix factual error in Lab 6.9 MITRE mapping (JS -> Java)~~ FIXED: T1059.007 -> T1059.004 (Unix Shell)
3. ~~Fix placeholder paths in Labs 3.1, 4.3, 4.5, 4.6~~ FIXED: replaced with discovery commands

### P1: Structural -- DONE
4. ~~Kill all dead-end checkpoint questions (11 labs affected)~~ FIXED: removed from 3.1-3.6, 4.1-4.3, 0.1
5. Move CI Integration sections to Resources > CI Recipes (27 labs) -- TODO (do during restructure)
6. ~~Add missing intro paragraphs to Labs 4.1, 4.2, 4.3~~ FIXED
7. Fix Labs 0.4, 0.5 structural issues (missing sections, wrong admonitions, wrong verify command) -- TODO

### P2: Content quality -- PARTIALLY DONE
8. Add real-world incident framing to 18 labs missing it -- TODO (do during restructure)
9. Add explanations before unexplained commands (14 labs) -- TODO (do during restructure)
10. ~~Fix grammar issues in Labs 6.1, 6.3, 9.3~~ FIXED
11. ~~Fix structural inconsistencies (phase naming in 8.4, 8.5; duplicate CI in 1.4; broken link in 5.5)~~ FIXED
12. ~~Remove double --- separators in Labs 5.1, 5.2, 5.3~~ FIXED
13. Fix deprecated COSIGN_EXPERIMENTAL in 4.6 -- TODO
14. Fix outdated SLSA version table in 4.4 -- TODO
15. Address Tier 9 interactivity gap (9.2, 9.3, 9.4 need simulated environments or honest framing as walkthroughs) -- TODO
16. Address Tier 7 passivity (7.3, 7.4, 7.5 need more student-driven exercises) -- TODO
17. ~~Fix table formatting in 6.8 (plaintext -> markdown)~~ FIXED
18. ~~Fix dot formatting in 8.6 (. -> -)~~ FIXED
