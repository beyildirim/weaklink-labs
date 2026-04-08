# Lab 3.4: Registry Confusion

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

## Catching Registry Confusion in the Wild

The core signal is a **container image pulled from a registry not on your approved list**. This indicates either misconfiguration or an active attack.

**Indicators:**

- Kubelet image pull events where resolved registry differs from expected
- Deployment manifests with unqualified image names (no registry hostname)
- Docker daemon pulling from mirrors when it should only use the private registry
- New repositories appearing in public registries matching your internal image names

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Malicious image with same name on higher-priority registry |
| **Masquerading: Match Legitimate Name** | [T1036.005](https://attack.mitre.org/techniques/T1036/005/) | Attacker's image uses same name and tag as legitimate image |

---

**Alerts:**

- "Container image pulled from unapproved registry"
- "Deployment uses unqualified image name"

**Triage steps:**

1. Check if the image reference is fully qualified with a registry hostname
2. Compare digest of pulled image against your private registry
3. Check Docker daemon config for `registry-mirrors` or multiple registries in search path
4. Scan the pulled image for unexpected binaries, scripts, or layers
5. Update the image reference to be fully qualified

**Prevention:** Enforce fully qualified names via admission controller. Remove `registry-mirrors` from production Docker daemon config.

---

## CI Integration

**`.github/workflows/registry-check.yml`:**

```yaml
name: Registry Qualification Check

on:
  pull_request:
    paths:
      - "k8s/**"
      - "deploy/**"
      - "helm/**"

jobs:
  check-registry-refs:
    runs-on: ubuntu-latest
    env:
      ALLOWED_REGISTRIES: "registry.internal.corp,gcr.io/distroless,registry.k8s.io"
    steps:
      - uses: actions/checkout@v4

      - name: Reject unqualified image names
        run: |
          FOUND=0
          for f in $(find k8s/ deploy/ helm/ -name '*.yml' -o -name '*.yaml' 2>/dev/null); do
            while IFS= read -r line; do
              IMAGE=$(echo "$line" | grep -oP 'image:\s*\K\S+')
              [ -z "$IMAGE" ] && continue
              if ! echo "$IMAGE" | grep -qE '^[a-z0-9.-]+[.:][a-z0-9]+/'; then
                echo "::error file=$f::Unqualified image name: $IMAGE"
                FOUND=1
              fi
            done < "$f"
          done
          if [ "$FOUND" -eq 1 ]; then
            exit 1
          fi
          echo "PASS: All image references are fully qualified."
```

---

## What You Learned

- **Docker implicitly resolves short names.** `myapp:latest` becomes `docker.io/library/myapp:latest` unless you specify a hostname.
- **Registry search order creates attack surface.** If Docker checks multiple registries, an attacker can win by being on a higher-priority one.
- **Fully qualified names eliminate ambiguity.** `registry:5000/myapp:latest` always pulls from your registry.

## Further Reading

- [Docker: Image Naming and Tagging](https://docs.docker.com/reference/cli/docker/image/tag/)
- [containerd: Registry Configuration](https://github.com/containerd/containerd/blob/main/docs/hosts.md)
- [Kyverno: Restrict Image Registries](https://kyverno.io/policies/best-practices/restrict-image-registries/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
