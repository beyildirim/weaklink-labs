# Contributing to WeakLink Labs

Thanks for your interest in contributing! This guide explains how to add a new lab.

## Lab Structure

Every lab is a self-contained directory with this structure:

```
labs/tier-N-topic/N.X-lab-name/
├── lab.yml              # Metadata (required)
├── docker-compose.yml   # Lab environment (required)
├── README.md            # 3-phase lab guide (required)
├── verify.sh            # Completion check (required)
├── hints/               # Progressive hints
│   ├── hint-1.md
│   ├── hint-2.md
│   └── hint-3.md
├── src/                 # Application code, configs, scripts
└── solution/            # Reference solution
```

## lab.yml Format

```yaml
id: "1.2"
title: "Dependency Confusion"
tier: 1
module: "package-security"
prerequisites: ["1.1"]
difficulty: beginner | intermediate | advanced
estimated_time: 30m
tags: ["pypi", "dependency-confusion", "pip"]
phase_understand: "Explore how pip resolves packages from multiple sources"
phase_break: "Exploit dependency confusion to execute malicious code"
phase_defend: "Pin packages and configure pip to prevent the attack"
```

## README.md Structure

Every lab guide follows the same 3-phase format:

```markdown
# Lab N.X: Title

Brief description of what this lab teaches and why it matters.

## Prerequisites

- Lab N.Y completed
- Basic understanding of [concept]

## Environment

Description of what's running and how to interact with it.

## Phase 1: Understand

Step-by-step exploration of how the system works normally.

## Phase 2: Break

Step-by-step attack scenario.

## Phase 3: Defend

Step-by-step mitigation and verification.

## What You Learned

Summary mapping to real-world relevance.

## Further Reading

Links to relevant resources.
```

## verify.sh Guidelines

- Must return exit code 0 on success, non-zero on failure
- Print clear messages about what passed and what didn't
- Check the DEFENSE, not just the attack (user should have fixed the issue)

## Docker Compose Guidelines

- Use images from `shared/` when available (pypiserver, gitea, registry)
- Keep environments minimal — only what the lab needs
- All services should start within 30 seconds
- Include health checks where possible
- Use named volumes for data that should persist during the lab

## Submitting a Lab

1. Fork the repo
2. Create your lab directory following the structure above
3. Test it: `weaklink start <your-lab-id>` → complete all 3 phases → `weaklink verify <your-lab-id>`
4. Submit a PR with a description of what the lab teaches
