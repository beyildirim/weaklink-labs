# Lab 7.5: Threat Modeling for Software Supply Chains

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../investigate/" class="phase-step upcoming">Investigate</a>
  <span class="phase-arrow">›</span>
  <a href="../validate/" class="phase-step upcoming">Validate</a>
  <span class="phase-arrow">›</span>
  <a href="../improve/" class="phase-step upcoming">Improve</a>
</div>

**Goal:** Learn STRIDE categories and trust boundaries in a supply chain context.

## Step 1: STRIDE framework

| Category | Question | Supply Chain Example |
|----------|----------|---------------------|
| **S**poofing | Can an attacker pretend to be a trusted entity? | Publish a package under a trusted maintainer's name (account takeover) |
| **T**ampering | Can an attacker modify data in transit or at rest? | Inject malicious code into a lockfile, modify a build artifact |
| **R**epudiation | Can an attacker deny their actions? | Push a malicious commit with a spoofed Git author |
| **I**nformation Disclosure | Can an attacker access data they shouldn't? | Exfiltrate CI secrets during pip install |
| **D**enial of Service | Can an attacker disrupt availability? | Publish a broken version of a critical dependency |
| **E**levation of Privilege | Can an attacker gain higher access? | Use stolen CI credentials to modify production infrastructure |

## Step 2: What is a trust boundary?

A trust boundary is a point where data or control crosses from one trust domain to another. In a supply chain context:

- Code moves between systems (developer laptop to Git, Git to CI, CI to registry)
- An identity assertion is made (author of a commit, publisher of a package)
- A package is fetched from an external source (public registry to your build)
- An artifact transitions between environments (staging to production)
