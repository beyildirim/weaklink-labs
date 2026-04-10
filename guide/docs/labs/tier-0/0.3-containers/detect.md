# Lab 0.3: How Containers Work

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

## Spotting Container Image Tampering

What to look for:

- Image pushes that overwrite existing tags (especially `latest`, `stable`, `production`)
- Pushes from unusual IPs, service accounts, or outside CI/CD pipelines
- Containers making outbound connections to unexpected destinations
- Unexpected `/debug`, `/admin`, `/shell`, or `/env` endpoints on container ports
- Image pull events where the digest differs from last known digest for that tag

### MITRE ATT&CK Mapping

| Technique | ID | What to Monitor |
|-----------|----|-----------------|
| Compromise Software Supply Chain | T1195.002 | Tag overwrites, digest changes, pushes outside deploy windows |
| Implant Internal Image | T1525 | New layers added, unexpected base image changes |
| Deploy Container | T1610 | Containers with no digest pin, unexpected child processes |

---

## How to Think About Detection

At this stage, the key habit is comparing what you expected to deploy with what actually ran.

Ask:

- Did the same tag suddenly resolve to a different digest?
- Was the image push performed by the expected pipeline or user?
- Did the running container expose behavior that the original image did not have?

If you cannot answer those questions quickly, your image trust model is too weak.

If you want concrete rule examples or CI enforcement snippets later, use the shared resources linked at the bottom of the page.

---

## What You Learned

- **Tags are mutable pointers.** `latest`, `v1.0`, even `stable` can be overwritten at any time without warning.
- **Registries accept overwrites silently.** Pushing a new image with the same tag replaces the old one.
- **Digest pinning is the defense.** Using `@sha256:...` in Dockerfiles and deployments prevents tag substitution attacks because digests are immutable.

## Further Reading

- [Docker Image Digests Explained](https://docs.docker.com/engine/reference/commandline/pull/#pull-an-image-by-digest)
- [Why You Should Pin Docker Image Digests](https://blog.chainguard.dev/pin-your-container-image-digests/)
- [OCI Distribution Specification](https://github.com/opencontainers/distribution-spec)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
