# Lab 9.1: Cloud Marketplace Poisoning

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Break</span>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

**Goal:** Discover the three hidden persistence mechanisms.

## Audit the running container

Audit the running container for hidden backdoors. Check for unexpected processes, open ports, scheduled tasks, SSH keys, and init scripts:

```bash
docker exec -it marketplace-test bash
ps aux
ss -tlnp
cat /etc/cron.d/*
cat /root/.ssh/authorized_keys
ls /etc/init.d/
```

## Backdoor 1: Phone-home cron job

```bash
cat /etc/cron.d/cloud-health-monitor
```

Runs every 5 minutes, sends hostname and public IP to `telemetry-cdn.cloud-analytics.io`. Disguised as "cloud health monitor." The attacker knows every instance running this image.

## Backdoor 2: Pre-installed SSH key

```bash
cat /root/.ssh/authorized_keys
```

Attacker's SSH public key pre-installed. Comment says "Marketplace deployment key - DO NOT REMOVE." The attacker has SSH root access on demand.

## Backdoor 3: Credential exfiltration on boot

```bash
cat /usr/local/bin/systemd-helper
```

Runs on boot: reads `/etc/shadow`, collects cloud credentials (`AWS_*`, `AZURE_*`, `GCP_*`, `TOKEN`, `SECRET`), queries instance metadata (`169.254.169.254`), exfiltrates via DNS (fallback: HTTP).

```bash
docker stop marketplace-test && docker rm marketplace-test
```

---

!!! success "Checkpoint"
    You should have identified all three backdoors (cron phone-home, SSH key, boot-time credential theft) and understand their persistence mechanisms.
