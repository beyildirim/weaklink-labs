# Hint 2: Building a Clean Base Image and Scanning

## Building From Scratch

The only way to trust an image is to build it yourself. Use a minimal base and install only what you need:

```dockerfile
FROM debian:bookworm-slim

# Install ONLY what you need -- no marketplace mystery meat
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Explicit SSH config -- no pre-installed keys
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh
# No authorized_keys file -- keys are injected at deploy time via cloud-init

# No cron jobs by default
RUN rm -rf /etc/cron.d/* /var/spool/cron/*

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## Scanning Marketplace Images

Before deploying any marketplace image, scan it:

```bash
# Filesystem scan for backdoors
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy image marketplace-webserver:latest

# Check for unexpected cron jobs
docker run --rm marketplace-webserver:latest \
    sh -c "cat /etc/crontab; ls -la /etc/cron.d/; crontab -l 2>/dev/null"

# Check for pre-installed SSH keys
docker run --rm marketplace-webserver:latest \
    find / -name "authorized_keys" -o -name "*.pub" 2>/dev/null

# Check for unexpected network listeners
docker run --rm marketplace-webserver:latest \
    sh -c "apt-get update && apt-get install -y net-tools && netstat -tlnp"
```

## Detection After Deployment

If you already deployed a marketplace image, check for compromise:

```bash
# Outbound connections from the instance
ss -tnp | grep -v '127.0.0.1'

# Cron jobs added post-deployment
diff <(docker run --rm marketplace-webserver:latest crontab -l 2>/dev/null) <(crontab -l 2>/dev/null)

# SSH keys not in your inventory
cat ~/.ssh/authorized_keys  # Compare against your key management system
```
