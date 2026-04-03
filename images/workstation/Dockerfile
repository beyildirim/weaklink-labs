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
    pip-audit \
    pipdeptree \
    pip-tools \
    setuptools \
    wheel \
    twine

# npm tools
RUN npm install -g depcheck

# Create non-root user
RUN useradd -m -s /bin/bash hacker

# Vulnerable pip configuration (this is what labs teach users to fix)
# --extra-index-url checks BOTH registries; pip picks the highest version
RUN mkdir -p /home/hacker/.config/pip
COPY pip.conf /home/hacker/.config/pip/pip.conf

# npm configuration pointing to Verdaccio
COPY .npmrc /home/hacker/.npmrc

# MOTD
COPY motd /etc/motd
RUN echo 'cat /etc/motd' >> /home/hacker/.bashrc

# weaklink-help script
COPY weaklink-help /usr/local/bin/weaklink-help
RUN chmod +x /usr/local/bin/weaklink-help

# Bash completion and prompt
RUN echo 'source /etc/bash_completion 2>/dev/null' >> /home/hacker/.bashrc \
    && echo 'export PS1="\[\033[1;32m\]hacker@weaklink\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\$ "' >> /home/hacker/.bashrc

# Git defaults
RUN git config --system user.email "hacker@weaklink.local" \
    && git config --system user.name "Hacker"

# Working directory
RUN mkdir -p /home/labs && chown hacker:hacker /home/labs
WORKDIR /home/labs

# Fix ownership
RUN chown -R hacker:hacker /home/hacker

USER hacker

CMD ["sleep", "infinity"]
