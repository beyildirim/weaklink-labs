# Lab 0.1: How Version Control Works

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step done">Defend</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Detect</span>
</div>

<div class="no-terminal-notice">Reference material. No terminal needed.</div>

## Spotting Malicious Commits in the Wild

What to look for:

- Direct pushes to protected branches bypassing PR workflow
- Commits modifying CI/CD files (`build.sh`, `.github/workflows/`, `Jenkinsfile`, `Makefile`)
- Outbound HTTP/DNS requests during build steps (curl, wget, nc)
- Build scripts writing to `/tmp/` or accessing environment variables containing secrets
- Force pushes that rewrite history

### MITRE ATT&CK Mapping

| Technique | ID | What to Monitor |
|-----------|----|-----------------|
| Compromise Software Supply Chain | T1195.002 | Direct pushes, CI file changes, unsigned commits |
| Unix Shell | T1059.004 | Unexpected child processes of build scripts |
| Automated Exfiltration | T1020 | Outbound connections during build, writes to /tmp |

---

## How to Think About Detection

At this stage, the important skill is not writing a full rule. It is recognizing when a repository change deserves escalation.

Start with three questions:

- Did someone bypass the normal review path?
- Did the change touch files that control builds or deployments?
- Did the next build suddenly make network calls, spawn shells, or touch secrets?

If the answer to any of those is yes, investigate the commit diff before treating the build as trustworthy.

If you want concrete rule examples or CI enforcement snippets later, use the shared resources linked at the bottom of the page.

---

## What You Learned

- **Direct pushes bypass review.** Without branch protection, anyone with write access can push malicious code undetected.
- **Commit messages can lie.** A commit saying "minor cleanup" can contain a backdoor. Diffs are the only truth.
- **Branch protection forces review.** Requiring PR approvals adds a human checkpoint before code enters the main branch.

## Further Reading

- [Git Basics (git-scm.com)](https://git-scm.com/book/en/v2/Getting-Started-Git-Basics)
- [GitHub Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-a-branch-protection-rule)
- [OWASP Top 10 CI/CD: Insufficient Flow Control](https://owasp.org/www-project-top-10-ci-cd-security-risks/CICD-SEC-06-Insufficient-Credential-Hygiene)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
