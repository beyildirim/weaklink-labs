# Hint 2: Writing Effective Detection Rules

## Splunk SPL Pattern

For dependency confusion, the key pattern is: a build server fetches an internal package name from a public registry.

```spl
index=proxy sourcetype=squid
  src_ip IN ("10.100.0.0/24")
  dest_host="pypi.org"
  uri_path="/simple/*"
| rex field=uri_path "/simple/(?<package_name>[^/]+)/"
| lookup internal_package_names package_name OUTPUT is_internal
| where is_internal="true"
```

The `lookup` references a CSV of your internal package names. Without it, you're blind.

## KQL Pattern

```kql
DeviceProcessEvents
| where InitiatingProcessFileName has_any ("pip", "pip3", "npm", "yarn")
| where ProcessCommandLine has "setup.py" or ProcessCommandLine has "install"
| where FileName has_any ("curl", "wget", "nc", "bash", "sh")
```

This catches the **process tree anomaly**: package manager -> setup.py -> shell/network tool.

## Suricata Pattern

Focus on HTTP POST from build servers to external IPs (exfiltration), and DNS queries with long base64 subdomains (DNS tunneling).

## False Positive Tuning

Common false positives:
- Legitimate packages that run post-install scripts (e.g., `grpcio` compiles C extensions)
- Build servers fetching from public PyPI for legitimate public packages
- Package manager telemetry (pip sends anonymous usage stats)

Allowlist known-good packages and their expected network behavior.
