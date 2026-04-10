# Lab 3.1: Container Image Internals

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Defend</span>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Inspecting All Layers and Using Minimal Images

### Defense 1: Always inspect full history

```bash
docker history --no-trunc <image>
```

Any image with `RUN rm` after a `COPY` or `ADD` is suspicious.

### Defense 2: Scan all layers, not just the final filesystem

```bash
trivy image --scanners vuln registry:5000/webapp:latest
```

Configure your scanner to inspect every layer, not just the final merged filesystem.

### Defense 3: Use minimal base images

Distroless and Chainguard images have no shell, no package manager, and minimal layers:

```bash
crane manifest registry:5000/webapp:latest | jq '.layers | length'
crane manifest cgr.dev/chainguard/static:latest | jq '.layers | length'
```

Fewer layers means less surface area for hidden content.

### Defense 4: Build from scratch when possible

For compiled languages (Go, Rust), build `FROM scratch`:

```dockerfile
FROM scratch
COPY --from=builder /app/binary /app/binary
ENTRYPOINT ["/app/binary"]
```

One layer. Nothing to hide in.
