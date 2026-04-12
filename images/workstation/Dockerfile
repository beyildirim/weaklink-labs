FROM python:3.11-slim

LABEL maintainer="WeakLink Labs"
LABEL description="WeakLink Labs workstation — where users do all lab work"

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    jq \
    vim \
    nano \
    less \
    tree \
    bash-completion \
    netcat-openbsd \
    dnsutils \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Node.js 20
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
       | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" \
       > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Python tools
RUN pip install --no-cache-dir \
    ansible-core \
    pip-audit \
    pipdeptree \
    pip-tools \
    PyYAML \
    setuptools \
    wheel \
    twine

COPY weaklink_platform /opt/weaklink_platform/weaklink_platform
ENV PYTHONPATH=/opt/weaklink_platform

# npm tools
RUN npm install -g depcheck

# ttyd (web terminal)
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
        aarch64|arm64) TTYD_ARCH=aarch64 ;; \
        *) TTYD_ARCH=x86_64 ;; \
    esac && \
    curl -fsSL -o /usr/local/bin/ttyd "https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.${TTYD_ARCH}" && \
    chmod +x /usr/local/bin/ttyd

# Docker CLI (connects to host runtime socket, mounted via Helm)
RUN curl -fsSL https://download.docker.com/linux/static/stable/$(uname -m)/docker-27.5.1.tgz \
    | tar xz --strip-components=1 -C /usr/local/bin docker/docker \
    && chmod +x /usr/local/bin/docker

# Supply chain security tools
RUN ARCH=$(uname -m) \
    && case "$ARCH" in aarch64) GOARCH=arm64; CRANE_ARCH=arm64 ;; *) GOARCH=amd64; CRANE_ARCH=x86_64 ;; esac \
    && curl -fsSL "https://github.com/google/go-containerregistry/releases/download/v0.20.2/go-containerregistry_Linux_${CRANE_ARCH}.tar.gz" \
       | tar xz -C /usr/local/bin crane && chmod +x /usr/local/bin/crane \
    && curl -fsSL -o /usr/local/bin/cosign "https://github.com/sigstore/cosign/releases/download/v2.4.1/cosign-linux-${GOARCH}" \
    && chmod +x /usr/local/bin/cosign \
    && curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin v1.17.0 \
    && curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin v0.86.1 \
    && curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin latest

# Helm (Tier 5 IaC labs) + kubectl (Tier 5.5 admission controller)
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash \
    && curl -fsSL -o /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/$(uname -m | sed 's/aarch64/arm64/;s/x86_64/amd64/')/kubectl" \
    && chmod +x /usr/local/bin/kubectl

# Create non-root user
RUN useradd -m -s /bin/bash hacker

# Vulnerable pip configuration (fallback for local docker-run testing;
# in K8s the Helm ConfigMap overrides this at the same path)
RUN mkdir -p /home/hacker/.config/pip
COPY images/workstation/pip.conf /home/hacker/.config/pip/pip.conf

# npm configuration pointing to Verdaccio
COPY images/workstation/.npmrc /home/hacker/.npmrc

# MOTD
COPY images/workstation/motd /etc/motd
RUN echo 'cat /etc/motd' >> /home/hacker/.bashrc

# weaklink-help script
COPY images/workstation/weaklink-help /usr/local/bin/weaklink-help
RUN chmod +x /usr/local/bin/weaklink-help

# Copy all lab source files as read-only golden copies, then flatten
# /opt/labs-raw/tier-1-package-security/1.2-dependency-confusion/src/ -> /opt/labs/1.2/
COPY labs/ /opt/labs-raw/
RUN mkdir -p /opt/labs && python3 - <<'PY'
from pathlib import Path
import shutil

from weaklink_platform.manifest import load_lab_manifest

raw_root = Path("/opt/labs-raw")
target_root = Path("/opt/labs")

for lab_dir in sorted(raw_root.glob("tier-*/*")):
    if not lab_dir.is_dir() or not (lab_dir / "lab.yml").exists():
        continue
    manifest = load_lab_manifest(lab_dir)
    src_dir = lab_dir / "src"
    if not src_dir.exists():
        continue
    target_dir = target_root / manifest.id
    shutil.copytree(src_dir, target_dir, dirs_exist_ok=True)
    for entrypoint in ("verify.sh", "verify.py"):
        source = lab_dir / entrypoint
        if source.exists():
            shutil.copy2(source, target_dir / entrypoint)
shutil.rmtree(raw_root)
PY

# Lab init/reset scripts
COPY images/workstation/lab-init /usr/local/bin/lab-init
COPY images/workstation/lab-reset /usr/local/bin/lab-reset
COPY images/workstation/verify-server.py /usr/local/bin/verify-server.py
RUN chmod +x /usr/local/bin/lab-init /usr/local/bin/lab-reset /usr/local/bin/verify-server.py

# Bash completion, prompt, and lab auto-cd
RUN echo 'source /etc/bash_completion 2>/dev/null' >> /home/hacker/.bashrc \
    && echo 'export PS1="\[\033[1;32m\]hacker@weaklink\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\$ "' >> /home/hacker/.bashrc \
    && printf '%s\n' \
       '# Auto-cd to current lab working directory' \
       'if [ -f /tmp/.weaklink-workdir ]; then' \
       '  _wl_dir=$(cat /tmp/.weaklink-workdir)' \
       '  [ -d "$_wl_dir" ] && cd "$_wl_dir"' \
       '  unset _wl_dir' \
       'fi' >> /home/hacker/.bashrc

# Git defaults
RUN git config --system user.email "hacker@weaklink.local" \
    && git config --system user.name "Hacker" \
    && git config --system credential.helper '!f() { echo "username=weaklink"; echo "password=weaklink"; }; f'

# Pre-create lab directories writable by hacker (lab-init writes to these)
RUN mkdir -p /app /etc/pip-configs /lab /repos /workspace /home/labs /runner \
    && chown hacker:hacker /app /etc/pip-configs /lab /repos /workspace /home/labs /runner \
    && touch /etc/pip.conf && chown hacker:hacker /etc/pip.conf
WORKDIR /home/labs

# Fix ownership
RUN chown -R hacker:hacker /home/hacker

USER hacker

# Verify API (port 7682) in background, ttyd (port 7681) in foreground
CMD bash -c "python3 /usr/local/bin/verify-server.py &>/dev/null & ttyd -W -p 7681 bash"
