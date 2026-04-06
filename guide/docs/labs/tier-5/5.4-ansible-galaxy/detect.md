# Lab 5.4: Ansible Galaxy and Collection Attacks

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step done">Defend</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Detect</span>
</div>

<div class="no-terminal-notice">Reference material. No terminal needed.</div>

## Catching Malicious Ansible Roles

The core signal is Ansible tasks performing actions outside the role's stated purpose. An NTP role touching `authorized_keys` is a high-confidence indicator.

**Key indicators:**

- Roles containing `authorized_key`, `user`, or `shell` modules unrelated to their stated purpose
- `ansible-galaxy install` pulling from public Galaxy instead of private hub
- SSH keys appearing on managed hosts outside your key management system
- Playbook runs modifying `/root/.ssh/`, `/etc/sudoers`, or `/etc/cron.d/`

| Indicator | What It Means |
|-----------|---------------|
| HTTP GET to `galaxy.ansible.com` from CI runners | Roles pulled from public Galaxy |
| SSH connection from managed host to unknown IP after Ansible run | Planted SSH key in use |
| New `authorized_keys` entries after Ansible run | Backdoor planted |

### CI Integration

Scan roles for dangerous patterns in every PR:

```yaml
name: Ansible Galaxy Role Security Check

on:
  pull_request:
    paths:
      - "requirements.yml"
      - "roles/**"

jobs:
  scan-roles:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Require version pins in requirements.yml
        run: |
          python3 << 'PYEOF'
          import yaml, sys
          with open("requirements.yml") as f:
              reqs = yaml.safe_load(f)
          errors = []
          for section in ["roles", "collections"]:
              for item in reqs.get(section, []):
                  if "version" not in item:
                      errors.append(f"{section}: {item.get('name', 'unknown')} missing version pin")
          if errors:
              for e in errors:
                  print(f"::error::{e}")
              sys.exit(1)
          PYEOF

      - name: Scan roles for dangerous patterns
        run: |
          FOUND=0
          DANGEROUS="authorized_key|\.ssh/|useradd|adduser|/etc/sudoers|/dev/tcp|raw_socket"
          for f in $(find roles/ -name "*.yml" -path "*/tasks/*" 2>/dev/null); do
            if grep -Pn "$DANGEROUS" "$f"; then
              echo "::warning file=$f::Dangerous task patterns. Manual review required."
              FOUND=1
            fi
          done
          [ "$FOUND" -eq 0 ] || exit 1
```

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Trojanized Galaxy role distributed via public registry |
| **Account Manipulation: SSH Authorized Keys** | [T1098.004](https://attack.mitre.org/techniques/T1098/004/) | Backdoor plants attacker SSH key in authorized_keys |

**Alert:** "Unauthorized SSH key added to managed host" or "Ansible Galaxy role downloaded from public registry"

**Triage steps:**

1. Identify which role was installed and from which source
2. Diff role content against a known-good version
3. Check Ansible run logs for which hosts the role was applied to
4. On affected hosts: audit `authorized_keys`, `cron`, `systemd` timers, `/etc/profile.d/`
5. If confirmed: rotate all SSH keys and re-provision from known-good images

---

## What You Learned

- **Galaxy roles execute with root privileges** across your entire fleet. No review process, no signing, no sandboxing.
- **Trojanized roles blend in.** An NTP role that also plants an SSH key looks nearly identical to a legitimate one.
- **Version pinning and private hubs are essential.** Without them, every `ansible-galaxy install` is a supply chain compromise opportunity.

## Further Reading

- [Ansible Galaxy Documentation](https://galaxy.ansible.com/docs/)
- [Ansible Automation Hub: Private Content](https://www.ansible.com/products/automation-hub)
- [MITRE ATT&CK: SSH Authorized Keys (T1098.004)](https://attack.mitre.org/techniques/T1098/004/)
