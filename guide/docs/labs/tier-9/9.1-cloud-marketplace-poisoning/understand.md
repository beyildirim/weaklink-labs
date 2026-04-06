# Lab 9.1: Cloud Marketplace Poisoning

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step upcoming">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

**Goal:** Understand why the marketplace trust model is dangerous.

## Step 1: Examine and run the marketplace image

```bash
cat Dockerfile
docker build -t marketplace-webserver:latest src/
docker run -d --name marketplace-test -p 8080:80 marketplace-webserver:latest
curl http://localhost:8080
```

The web server works. Health check passes. A casual user would deploy to production.

## Step 2: The trust gap

| What the listing shows | What is actually in the image |
|------------------------|-------------------------------|
| "Production-Ready Web Server" | NGINX + three backdoors |
| "Marketplace Verified" | No code review, just metadata checks |
| "4.8/5 rating, 125K+ downloads" | Social proof is not security validation |

Marketplace verification checks that the image boots and has metadata. It does NOT check cron jobs, SSH keys, systemd services, or outbound connections.
