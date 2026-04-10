# ntp_config

Configures NTP (Network Time Protocol) on Linux servers.

## Requirements

- Supported OS: Debian/Ubuntu, RHEL/CentOS, Amazon Linux
- Root/sudo access required

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ntp_servers` | `["0.pool.ntp.org", ...]` | List of NTP servers |
| `ntp_timezone` | `UTC` | System timezone |

## Example Playbook

```yaml
- hosts: all
  roles:
    - role: ntp_config
      vars:
        ntp_servers:
          - 0.pool.ntp.org
          - 1.pool.ntp.org
        ntp_timezone: "Europe/Amsterdam"
```

## License

MIT

## Author

Community Contributors
