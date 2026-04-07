# Hint 1: Where to Start with Detection Rules

Each attack type has a distinctive log signature. Start by identifying the **data source** for each:

| Attack Type | Primary Log Source | Key Indicator |
|---|---|---|
| Dependency Confusion | Proxy logs, pip install output | Internal package name resolved from public registry |
| Typosquatting | Package manager logs | Package name with edit distance 1-2 from a popular package |
| Lockfile Injection | Git diff / CI logs | `requirements.txt` hash changed but package name/version didn't |
| Manifest Confusion | npm install logs | `scripts.install` in package.json but not in registry metadata |
| Phantom Dependencies | Build logs | Import of a package not listed in requirements/package.json |

For Splunk, your queries will target `index=proxy` for network-based detection and `index=edr` for process-based detection.

For Suricata, focus on **network indicators**: HTTP requests to public registries from build servers, and outbound connections from `setup.py` child processes.

Look at the sample logs in `src/logs/`. Each file simulates one attack type. Study the log format before writing queries.
