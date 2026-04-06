# Lab 9.1: Cloud Marketplace Poisoning

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

**Goal:** Build your own base images, scan marketplace images, verify provenance.

## Fix 1: Build from minimal base

```dockerfile
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends nginx \
    && rm -rf /var/lib/apt/lists/*
RUN rm -rf /etc/cron.d/* /var/spool/cron/* /root/.ssh
RUN useradd -r -s /bin/false nginx-user
USER nginx-user
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

No SSH server, no cron, no extra tools. Monitoring via external systems.

## Fix 2: Scan images before deployment

```bash
trivy image marketplace-webserver:latest
docker run --rm marketplace-webserver:latest \
    sh -c "find /etc/cron* /var/spool/cron -type f 2>/dev/null | xargs cat"
docker run --rm marketplace-webserver:latest \
    find / -name "authorized_keys" -o -name "*.pub" 2>/dev/null
docker history --no-trunc marketplace-webserver:latest
```

## Fix 3: Use Infrastructure-as-Code exclusively

Replace marketplace images with Packer templates building from official base images with audited provisioning.

## Final verification

```bash
weaklink verify 9.1
```
