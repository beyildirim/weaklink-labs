# Facilitator Guide

<div class="lab-meta">
  <span>For team leads and managers</span>
  <span>Rolling out WeakLink Labs as team training</span>
</div>

This guide is for people like Aylin -- a SOC team lead managing 8 analysts with wildly different experience levels, limited training budget, and a CISO who wants to see results. You don't need to be a supply chain security expert. You need to get your team through these labs and come out the other side with real operational improvements.

**Time commitment:** ~3-4.5 hours per person, spread over 2-4 weeks.

**Cost:** $0. WeakLink Labs is open source. The only cost is your analysts' time.

---

## Pre-Rollout Checklist

Before you announce this to your team, do the prep work. Nothing kills training momentum faster than "sorry, the lab environment is broken -- we'll try again next week."

!!! warning "Do this yourself first"
    You need to have personally completed at least two labs before facilitating. Otherwise you're asking your team to trust a process you haven't tested.

- [ ] **Set up the environment.** Get minikube running. Run `./start.sh` and confirm it completes without errors. Run `weaklink shell` and verify you can reach the lab services. Do this on a machine that matches what your analysts will use.
- [ ] **Run Labs 0.2 and 1.2 yourself.** Lab 0.2 (How Package Managers Work) gives you the foundation. Lab 1.2 (Dependency Confusion) is the showstopper demo -- you need to know how it feels to execute it.
- [ ] **Identify your team's skill levels.** Have experienced analysts take the placement test (`weaklink assess`) -- if they score 8/10 or higher, they skip Tier 0 automatically. For everyone else, ask in your next standup: "Has anyone heard of dependency confusion? Typosquatting? Lockfile injection?" The answers will tell you where to start.
- [ ] **Decide which labs are mandatory vs. optional.** For most SOC teams: Tier 0 is mandatory for juniors, optional for seniors. Tier 1 Labs 1.1-1.3 are mandatory for everyone. Labs 1.4-1.6 are recommended for seniors and optional for others.
- [ ] **Block calendar time.** Two 1-hour blocks per week for 2 weeks. Put it on the shared calendar now. If it's not on the calendar, it won't happen.
- [ ] **Test the reporting.** Run `weaklink report` after completing a lab to make sure the verification and reporting pipeline works end-to-end.

---

## Recommended Training Plan

This is a 3-4 week rollout designed for a team of 6-12 analysts. Adjust timing based on your team size and schedule.

### Week 1: Kickoff and Foundations

!!! tip "Tuesday Team Meeting (30 minutes)"
    **Live demo of Lab 1.2 -- Dependency Confusion.**

    This is your hook. Open a terminal on the projector. Run through the attack live: publish a malicious package to the public registry, watch pip install it instead of the internal one, show the "compromised" output.

    Then ask: *"Could we detect this today? If this happened in our CI pipeline right now, would any of our alerts fire?"*

    The room will be quiet. That's the point.

**Self-paced assignments:**

| Lab | Time | Who |
|-----|------|-----|
| 0.1 -- How Version Control Works | ~25 min | Juniors (seniors can skip) |
| 0.2 -- How Package Managers Work | ~25 min | Everyone |
| 0.3 -- How Containers Work | ~30 min | Everyone |

!!! note "For experienced analysts"
    If someone claims they already know this material, don't argue. Tell them to start with Lab 1.1 instead and verify their completion with `weaklink verify 1.1`. If they breeze through it, great -- they just saved 80 minutes.

---

### Week 2: Core Attacks

**Self-paced assignments:**

| Lab | Time | Who |
|-----|------|-----|
| 1.1 -- Dependency Resolution | ~30 min | Everyone |
| 1.2 -- Dependency Confusion | ~30 min | Everyone |
| 1.3 -- Typosquatting | ~25 min | Everyone |

!!! tip "Thursday Check-in (15 minutes)"
    Quick standup format. Go around the room:

    1. Which labs did you complete?
    2. What surprised you?
    3. Any blockers?

    Common blockers at this stage: environment issues (minikube ran out of memory), confusion about which terminal to use (host vs. workstation), or someone who hasn't started yet. Fix environment issues immediately. For the person who hasn't started -- pair them with someone who has.

---

### Week 3: Advanced Labs

**Self-paced assignments:**

| Lab | Time | Who |
|-----|------|-----|
| 1.4 -- Lockfile Injection | ~30 min | Recommended for senior analysts |
| 1.5 -- Manifest Confusion | ~30 min | Recommended for senior analysts |
| 1.6 -- Phantom Dependencies | ~30 min | Recommended for senior analysts |

!!! tip "Tuesday Team Meeting (45 minutes)"
    **Team discussion.** This is where the training translates to operational value.

    Use the discussion questions below. The goal is not to quiz people -- it's to connect the lab exercises to your actual environment. You should walk out of this meeting with a list of 3-5 concrete actions.

    Example outcomes:

    - "We need to add lockfile diffing to our PR review checklist"
    - "Our CI pipeline uses `--extra-index-url` -- we need to fix that this sprint"
    - "Nobody on the team was reviewing dependency updates -- assign an owner"

---

### Week 4: Reporting

Collect individual reports and compile team results.

```bash
# Each analyst runs this on their machine
weaklink report --json > reports/$(whoami).json
```

```bash
# You compile the team report
weaklink report --team reports/*.json
```

!!! info "Present to the CISO"
    See the [Reporting to the CISO](#reporting-to-the-ciso) section below for a template. Schedule 15 minutes. Bring the team report, the list of actions from the Week 3 discussion, and the cost comparison.

---

## Discussion Questions

These are designed for the Week 3 team meeting, but you can use them anytime. Pick 2-3 per lab -- you don't need to cover all of them.

### Tier 0: Foundations

#### Lab 0.1 -- How Version Control Works

1. "Who has push access to our main branches? Could a compromised developer account push directly to main?"
2. "Do we have branch protection rules on all our critical repositories? When was the last time we audited them?"
3. "If an attacker got access to a developer's Git credentials, what's the blast radius? How many repos could they touch?"

#### Lab 0.2 -- How Package Managers Work

1. "How many of us have run `pip install` without checking what the package actually does? Be honest. What would we need to change about our workflow?"
2. "Do we know how many dependencies our applications pull in transitively? Has anyone ever counted?"
3. "If a package we depend on was compromised tomorrow, how would we even know?"

#### Lab 0.3 -- How Containers Work

1. "Are we using image tags or digests in our deployments? What happens if someone pushes a new image to the same tag?"
2. "Who controls our base images? If our base image was backdoored, which of our services would be affected?"
3. "How old are the base images in our production containers? When was the last time we rebuilt them?"

### Tier 1: Package Security

#### Lab 1.1 -- Dependency Resolution

1. "Do we use `--extra-index-url` or `--index-url` in any of our pip configurations? Which one, and what's the security difference?"
2. "How does our package manager decide which version to install when the same package name exists in multiple registries? Did anyone on the team know the answer before this lab?"
3. "If we had to audit our dependency resolution configuration across all our projects right now, how long would it take? Who would do it?"

#### Lab 1.2 -- Dependency Confusion

1. "If dependency confusion happened in our CI pipeline right now, what secrets would be exposed? How quickly could we rotate them?"
2. "Do we have any internal package names that aren't registered on public PyPI or npm? Who's responsible for claiming those names?"
3. "Could our monitoring detect an unexpected package source change? What would the alert look like?"

#### Lab 1.3 -- Typosquatting

1. "Has anyone on the team ever made a typo in a package name during installation? What happened?"
2. "Do we have an approved package list or allowlist? If not, what would it take to create one for our most critical projects?"
3. "If a developer installed a typosquatted package on their local machine, would our endpoint detection catch the exfiltration?"

#### Lab 1.4 -- Lockfile Injection

1. "Who reviews lockfile changes in our PRs? How confident are we that we'd catch a hash swap in a 2,000-line lockfile diff?"
2. "Do we have CI checks that verify lockfile integrity? If not, how hard would it be to add one?"
3. "When was the last time someone on the team actually read a lockfile diff instead of just approving it?"

#### Lab 1.5 -- Manifest Confusion

1. "Do we trust `npm view` output when evaluating packages? After this lab, should we?"
2. "If the registry metadata says a package has zero dependencies but the tarball actually installs three, would any of our tools catch that?"
3. "How do we verify that what we see on a package's registry page is actually what gets installed?"

#### Lab 1.6 -- Phantom Dependencies

1. "Do any of our projects import packages that aren't in their `package.json`? How would we find out?"
2. "If a framework we depend on drops a transitive dependency in a minor version bump, would our CI catch it before production breaks?"
3. "What's our process for auditing transitive dependencies? Do we even have one?"

---

## Handling Different Skill Levels

Every team has a mix. Here's how to handle the three archetypes you'll encounter.

### The Skeptical Senior

**Profile:** 10-15 years of experience. Has seen training programs come and go. Thinks supply chain security is a developer problem, not a SOC problem. Will openly question why they're doing this.

!!! abstract "Strategy: Position them as evaluators, not students"
    Don't fight the skepticism -- use it. Their critical eye is exactly what you need.

**What to do:**

- Skip them past Tier 0 entirely. Assign Labs 1.4 (Lockfile Injection), 1.5 (Manifest Confusion), and 1.6 (Phantom Dependencies) directly -- these are the labs most likely to teach them something new.
- Ask them to present their findings to the team in the Week 3 discussion. Seniors who teach retain more and buy in faster.
- Give them a challenge: *"After completing Lab 1.2, write a SIEM detection rule that would catch dependency confusion in our CI logs. Bring it to the team meeting."*
- If they still resist: *"I hear you. Take Lab 1.2 -- it's 30 minutes. If you already know everything in it, you'll be done in 15. But I need you to evaluate whether this is useful for the juniors."*

### The Junior Analyst

**Profile:** 1-3 years in the SOC. Eager, sometimes overwhelmed. Knows how to triage alerts but has never thought about where software dependencies come from. Might be intimidated by the command line.

!!! abstract "Strategy: Build confidence, not speed"
    Juniors need wins early. Tier 0 exists for them.

**What to do:**

- Start with Tier 0, no exceptions. Even if they say they know Git and Docker. The labs build mental models they'll need for Tier 1.
- Pair them with a senior for Labs 1.1-1.3. Not as hand-holding -- as collaboration. Both benefit.
- Set explicit expectations: *"You have two weeks. Two labs per week. That's one hour a week. You can do this."*
- When they complete a lab, acknowledge it publicly in the team channel or standup. Completion matters more than speed.
- If they get stuck, point them to the built-in hints (`weaklink hint <lab-id>`) before jumping in to help. Let them work through it.

### The Non-Technical Lead (You)

**Profile:** You manage the team. You set priorities, run meetings, and report to the CISO. You haven't written code in years, or maybe ever. You're wondering if you should even do the labs yourself.

!!! abstract "Strategy: You don't need to be the expert. You need to be the facilitator."
    Your value is connecting the labs to team operations, not explaining the technical details.

**What to do:**

- Do Labs 0.2 and 1.2 yourself. These are the most accessible labs and they give you enough context to facilitate every discussion.
- You don't need to understand every detail of lockfile injection. You need to ask: *"How does this change our runbook? Do we need a new detection rule? Who owns this?"*
- In meetings, your job is to turn "that was interesting" into "here's what we're going to do about it."
- Don't pretend to be technical. Your team will respect you more for saying *"I did Lab 1.2 and I want to understand -- could this happen to us?"* than for faking expertise.

---

## Reporting to the CISO

Your CISO wants three things: what you did, what you found, and what you're going to do about it. Here's a template.

### Email Template

!!! example "Subject: Supply Chain Security Training -- Results and Recommendations"

    Hi [CISO name],

    We completed a 3-week supply chain security training program using WeakLink Labs, an open-source hands-on training platform. Here are the results.

    **What we covered:**

    - [X] analysts completed training covering [Y] attack techniques including dependency confusion, typosquatting, lockfile injection, and manifest confusion
    - Each analyst spent approximately [Z] hours on hands-on labs executing real attacks in an isolated environment, then building the defenses

    **Key findings:**

    - [Percentage]% of the team was unfamiliar with dependency confusion prior to training -- the #1 supply chain attack vector in 2024-2025
    - We identified [N] gaps in our current detection capabilities, specifically: [list them]
    - [Specific finding, e.g., "Our CI pipeline uses `--extra-index-url` which is vulnerable to dependency confusion. We have a fix ready for review."]

    **Operational impact:**

    - [Actions taken, e.g., "Added lockfile integrity verification to our CI pipeline"]
    - [Actions taken, e.g., "Created SIEM detection rules for unexpected package source changes"]
    - [Actions taken, e.g., "Registered our internal package names on public PyPI to prevent name squatting"]

    **Cost comparison:**

    | Training | Cost per seat | Total (8 analysts) | Format |
    |----------|--------------|---------------------|--------|
    | SANS SEC522 | ~$8,000 | ~$64,000 | 5-day classroom |
    | TryHackMe Teams | ~$300/year | ~$2,400/year | Browser-based |
    | WeakLink Labs | $0 | $0 | Self-hosted, hands-on |

    WeakLink Labs is not a replacement for comprehensive security training, but for supply chain security specifically, it delivered hands-on experience with real attack techniques at zero cost.

    **Recommended next steps:**

    1. [Specific action with owner and timeline]
    2. [Specific action with owner and timeline]
    3. [Specific action with owner and timeline]

    Happy to walk through the detailed findings. Team report attached.

---

## Metrics to Track

You need numbers to justify the time investment and to measure whether the training actually changed anything.

### During Training

| Metric | How to measure | Target |
|--------|---------------|--------|
| Labs completed per analyst | `weaklink report` | 6+ labs (all of Tier 0 + Tier 1 core) |
| Completion rate | Completed / assigned | >80% of team |
| Time to completion | Estimate from lab timestamps | Within the 3-week window |
| Team discussion participation | Your observation | Everyone contributes at least once |

### After Training (30-90 days)

| Metric | How to measure | Why it matters |
|--------|---------------|----------------|
| Follow-up actions implemented | Track in your project board | e.g., "Added lockfile verification to CI" |
| Detection rules created | Count new SIEM/SOAR rules | Direct output of the training |
| Incidents where training improved triage | Analyst self-report or case review | The real ROI |
| Dependency audit coverage | % of projects with verified configs | Shows sustained behavior change |
| Internal package names claimed | Count of names registered on public registries | Prevents dependency confusion proactively |

!!! tip "The metric that matters most"
    The single most valuable outcome is not a number -- it's when an analyst triaging an alert says *"Wait, this looks like dependency confusion"* and knows what to do next. Track that qualitatively. Ask about it in your 1:1s.

---

## Common Objections and Responses

You will hear these. Be ready.

### "I don't have time."

Each lab takes 25-30 minutes. The plan asks for two labs per week -- that's one hour. If someone has time for a 1-hour team meeting, they have time for this. Block it on the calendar as protected time.

### "This is developer stuff, not SOC stuff."

Lab 1.2 (Dependency Confusion) directly explains the supply chain alerts you're triaging. The attack starts with a package install and ends with secrets exfiltration -- that's a SOC alert. If you don't understand the attack chain, you're triaging blind. Try it.

### "We already have SANS training."

SANS covers broad security fundamentals. WeakLink covers the specific supply chain attack techniques that are hitting organizations right now -- dependency confusion, typosquatting, lockfile injection. SANS teaches you theory. WeakLink makes you execute the attack, then build the defense. They're complementary, not competing. Also, this one is free.

### "I already know this."

Great. Take the placement test: `weaklink assess`. Score 8/10 and you skip Tier 0 entirely. Then run through Lab 1.2 -- it's 30 minutes. If you already know everything in it, you'll be done in 15. Most people who say this are surprised by at least one lab. If you genuinely know it all, your time is better spent helping the juniors and writing detection rules.

### "My manager won't approve the time."

Show them the cost comparison: SANS is $8K/seat, TryHackMe is $300/seat/year, WeakLink is $0 + 3-4 hours of analyst time. If your manager won't approve 4 hours for supply chain security training that costs nothing, the problem isn't the training.

### "The environment won't run on my machine."

WeakLink Labs requires minikube with at least 4GB of RAM allocated. If someone's machine can't handle that, pair them with someone whose machine can -- screen share or sit together. The labs work fine with two people at one terminal. File an issue on GitHub if you hit a genuine environment bug.

---

## Quick Reference: Lab Summary

| Lab | Time | Difficulty | Attack Technique | Key Takeaway |
|-----|------|------------|-----------------|--------------|
| 0.1 | ~25 min | Beginner | Malicious commit injection | Branch protection rules matter |
| 0.2 | ~25 min | Beginner | -- | Package managers are implicit trust machines |
| 0.3 | ~30 min | Beginner | Mutable tag swap | Pin container images by digest, not tag |
| 1.1 | ~30 min | Intermediate | -- | Resolution order determines what gets installed |
| 1.2 | ~30 min | Intermediate | Dependency confusion | Higher version from public registry wins |
| 1.3 | ~25 min | Intermediate | Typosquatting | One character typo = full compromise |
| 1.4 | ~30 min | Intermediate | Lockfile hash swap | Nobody reads lockfile diffs |
| 1.5 | ~30 min | Intermediate | Manifest mismatch | Registry metadata can lie |
| 1.6 | ~30 min | Intermediate | Phantom dependency hijack | Implicit dependencies are a ticking bomb |

**Total time for all 9 labs:** ~4.5 hours

**Minimum recommended set (Tier 0 + Tier 1 core):** Labs 0.1-0.3, 1.1-1.3 = ~2.75 hours
