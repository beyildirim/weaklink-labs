# Lab 3.2: Tag Mutability Attacks

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

## Finding Tag Overwrites in Production

The core signal is a **tag push where the tag already existed with a different digest**. The secondary signal is a **deployment pulling a different digest than it previously ran**.

**Indicators:**

- Registry audit logs showing `PUT` to an existing tag (tag overwrite)
- Deployment events where pulled image digest differs from previously running digest
- Pod restarts coinciding with registry push events
- `imagePullPolicy: Always` on production deployments (increases exposure)

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Implant Internal Image** | [T1525](https://attack.mitre.org/techniques/T1525/) | Attacker overwrites a legitimate tag with a backdoored image |
| **Deploy Container** | [T1610](https://attack.mitre.org/techniques/T1610/) | Kubernetes automatically deploys the attacker's container on next pull |

---

**Alerts:**

- "Registry tag overwrite: webapp:1.0.0 pushed with new digest"
- "Kubernetes deployment pulled different digest for same image tag"

**Triage steps:**

1. Compare new digest against previous digest for the same tag
2. Check who pushed the new image (registry audit log: user, IP, timestamp)
3. Inspect new image layers for unexpected binaries or scripts
4. If unauthorized: re-tag the known-good digest and redeploy
5. Rotate any secrets accessible to pods that ran the compromised image

**Prevention:** Enable tag immutability in your registry (ECR, GCR, Harbor all support this).

---

## CI Integration

**`.github/workflows/digest-check.yml`:**

```yaml
name: Image Digest Enforcement

on:
  pull_request:
    paths:
      - "k8s/**"
      - "deploy/**"
      - "helm/**"

jobs:
  check-digests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Reject tag-only image references
        run: |
          FOUND=0
          for f in $(find k8s/ deploy/ helm/ -name '*.yml' -o -name '*.yaml' 2>/dev/null); do
            while IFS= read -r line; do
              if echo "$line" | grep -qE 'image:.*:[a-zA-Z0-9._-]+$' && \
                 ! echo "$line" | grep -q '@sha256:'; then
                echo "::error file=$f::Tag-only image reference found: $line"
                FOUND=1
              fi
            done < "$f"
          done
          if [ "$FOUND" -eq 1 ]; then
            exit 1
          fi
          echo "PASS: All image references use digests."
```

---

## What You Learned

- **Tags are mutable.** `webapp:1.0.0` today can point to a different image tomorrow. Only digests (`@sha256:...`) are immutable.
- **Tag overwrites are silent.** Registries do not alert when a tag is moved. Kubernetes does not verify content.
- **Digest pinning is the fix.** Referencing images by `@sha256:` ensures you always get the intended image.

## Further Reading

- [OCI Distribution Spec: Manifest](https://github.com/opencontainers/distribution-spec/blob/main/spec.md)
- [Kyverno: Verify Image](https://kyverno.io/policies/best-practices/require-image-digest/)
- [ECR: Image Tag Immutability](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-tag-mutability.html)
