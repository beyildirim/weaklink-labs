FROM python:3.11-slim

LABEL maintainer="WeakLink Labs"
LABEL description="Lab setup job — seeds all registries with lab content"

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    jq \
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

# Python build tools
RUN pip install --no-cache-dir PyYAML setuptools wheel pip-tools

# Copy ALL lab source packages into the image
# Build context is the repo root, so labs/ is available
COPY labs/ /labs/
COPY weaklink_platform /opt/weaklink_platform/weaklink_platform
ENV PYTHONPATH=/opt/weaklink_platform

# Copy the entrypoint script
COPY images/lab-setup/setup-labs.py /setup-labs.py
RUN chmod +x /setup-labs.py

# Git config for repo seeding
RUN git config --global user.email "admin@weaklink.local" \
    && git config --global user.name "WeakLink Admin" \
    && git config --global init.defaultBranch main

ENTRYPOINT ["/setup-labs.py"]
