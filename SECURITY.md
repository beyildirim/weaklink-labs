# Security Policy

WeakLink Labs is a **local training environment** for software supply chain security. The repository intentionally contains vulnerable configurations, fake credentials, malicious package examples, and exploit steps used for education.

## Reporting a Vulnerability

Use **GitHub's private vulnerability reporting** for this repository when available.

- Preferred: open a private vulnerability report through GitHub Security Advisories for `beyildirim/weaklink-labs`.
- If private reporting is not available in your GitHub view, open a regular issue asking for a private contact path **without including exploit details, secrets, or proof-of-concept code**.

Include:

- affected file, workflow, image, or service
- impact and realistic attack path
- reproduction steps using the local training environment
- any suggested mitigation

## Scope

Report these privately:

- repository automation or release pipeline flaws
- unintended secret exposure
- container, Helm, or Docker Compose issues that weaken the platform outside the intended lab scenario
- documentation errors that would cause learners to expose real infrastructure or credentials

Do **not** report these as vulnerabilities by themselves:

- intentionally vulnerable lab content
- seeded fake credentials, fake tokens, or weak local passwords used for exercises
- malicious packages, scripts, images, or indicators included as training material
- insecure-by-design defaults that are already documented as local-only training behavior

## Safe Use

WeakLink Labs is not intended for:

- public Internet deployment
- shared multi-user hosting
- connection to real production systems, registries, clusters, or cloud accounts

Keep the environment isolated and use throwaway data only.

## Supported Versions

Security fixes are expected to land on `main` first. Tagged releases may receive fixes later or only through a newer release.
