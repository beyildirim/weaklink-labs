# Lab 1.3: Typosquatting

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

## Catching and Preventing Typosquatting

### Defense 1: Remove the typosquatted package

```bash
pip uninstall reqeusts -y
rm -f /tmp/typosquat-exfil
```

### Defense 2: Install the correct package

```bash
pip install --index-url http://pypi-private:8080/simple/ --trusted-host pypi-private requests
```

### Defense 3: Create a pinned requirements.txt

Never install packages by typing names manually. Use a requirements file with exact version pins:

```bash
cat > /app/requirements.txt << 'EOF'
requests==2.31.0
EOF
```

### Defense 4: Validate against an allowlist

```bash
bash /app/scripts/validate_packages.sh /app/allowlist.txt
```

### Defense 5: Run pip-audit

```bash
pip-audit 2>/dev/null || echo "pip-audit found no known vulnerabilities"
```

`pip-audit` catches packages with reported CVEs but may not catch brand-new typosquatting attacks. Defense-in-depth (allowlists + pinning + review) matters.
