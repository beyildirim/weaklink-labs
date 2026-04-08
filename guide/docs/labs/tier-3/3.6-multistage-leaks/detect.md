# Lab 3.6: Multi-Stage Build Leaks

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

## Finding Leaked Secrets in Production Images

The key signal is **secrets found in container image layers or config metadata**, surfaced by image scanning or when an attacker uses a leaked credential.

**Indicators:**

- Image scanning results showing API keys, passwords, or private keys in any layer
- `ENV` instructions in image history containing key/token/password/secret patterns
- Build logs showing `ARG` with secret values in plaintext
- Authentication logs showing valid credentials used from unexpected sources

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Unsecured Credentials: Credentials In Files** | [T1552.001](https://attack.mitre.org/techniques/T1552/001/) | Secrets in image layers, ENV variables, or copied files accessible to anyone with pull access |
| **Implant Internal Image** | [T1525](https://attack.mitre.org/techniques/T1525/) | Deliberately crafted image with hardcoded credentials for lateral movement |

---

**Alert:** "Secret detected in container image layer" or "API key found in image environment variables"

Developers routinely pass secrets via `ARG`/`ENV` because it is convenient. The risk escalates when images are pushed to shared registries: everyone with pull access can extract the secrets.

**Triage steps:**

1. Identify the secret type (API key, database password, private key)
2. Check if the secret is still valid. **Rotate immediately** if so
3. Determine blast radius: which registries have this image, who has pull access
4. Rebuild using BuildKit secrets and push a clean replacement
5. Audit other build pipelines for the same pattern

---

## CI Integration

**`.github/workflows/image-secret-scan.yml`:**

```yaml
name: Image Secret Scanner

on:
  push:
    paths:
      - "Dockerfile*"
      - ".dockerignore"

jobs:
  scan-secrets:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Verify .dockerignore exists
        run: |
          if [ ! -f .dockerignore ]; then
            echo "::error::.dockerignore is missing"
            exit 1
          fi
          for pattern in ".env" "*.key" "*.pem" "credentials"; do
            if ! grep -q "$pattern" .dockerignore; then
              echo "::warning::.dockerignore does not exclude '$pattern'"
            fi
          done

      - name: Check for ENV/ARG secret patterns
        run: |
          if grep -iE '^(ENV|ARG)\s+.*(KEY|TOKEN|PASSWORD|SECRET|CREDENTIAL)' Dockerfile; then
            echo "::error::Dockerfile uses ENV/ARG for secret values. Use --mount=type=secret instead."
            exit 1
          fi

      - name: Build image
        run: DOCKER_BUILDKIT=1 docker build -t scan-target:latest .

      - name: Scan for secrets with Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: scan-target:latest
          scanners: secret
          severity: CRITICAL,HIGH
          exit-code: 1
```

---

## What You Learned

- **Multi-stage builds do not automatically protect secrets.** Secrets leak through ENV, ARG, overbroad COPY, and build context.
- **`ARG` and `ENV` values persist in layer history.** `docker history --no-trunc` and `crane config` expose them as cleartext.
- **BuildKit `--mount=type=secret` is the correct pattern.** It mounts a secret at build time without writing it to any layer.

## Further Reading

- [BuildKit Dockerfile secrets](https://docs.docker.com/build/building/secrets/)
- [Dive: exploring image layers](https://github.com/wagoodman/dive)
- [Trivy secret scanning](https://aquasecurity.github.io/trivy/latest/docs/scanner/secret/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
