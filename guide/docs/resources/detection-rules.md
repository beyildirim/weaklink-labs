# Detection Rule Library

Detection rules for every attack technique covered in WeakLink Labs. This library contains two categories of rules:

**Production-ready Sigma rules** use standard log sources (proxy, EDR/Sysmon, DNS, Kubernetes audit logs, CloudTrail, web server logs) that compile through `sigma-cli` or `pySigma` into any supported SIEM backend. These can be converted and deployed directly.

**Detection logic patterns** describe detection strategies for CI/CD pipelines, VCS platforms, container registries, SBOM validators, and other telemetry sources that have no standard Sigma backend. These rules document the detection logic and field mappings you need, but require translation into your SIEM's native query language (KQL, SPL, Lucene) and adaptation to your organization's log pipeline.

All rules are organized by tier and attack category. Each rule references the lab where the technique is taught and maps to MITRE ATT&CK. For conceptual detection guidance (indicators, triage workflows, false positive rates), see the Detect phase of each individual lab.

---

## Production-Ready Sigma Rules

The rules in this section use standard Sigma log sources. Convert them with `sigma-cli` or `pySigma` and deploy to your SIEM (Splunk, Elastic, Microsoft Sentinel).

<details open>
<summary>Tier 1: Package Security</summary>

### Dependency Resolution: Public Registry Fallback

**Lab:** 1.1 Dependency Resolution | **Log Source:** Web proxy

Detects build infrastructure contacting public PyPI when a private registry is configured. Build servers should never resolve packages from `pypi.org` directly.

```yaml
title: Build Server Contacting Public PyPI
id: a1b2c3d4-1101-4a5b-8c7d-e8f9a0b1c2d3
status: experimental
description: >
  Build infrastructure resolving packages from public PyPI indicates
  misconfigured extra-index-url or active dependency confusion attack.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: proxy
  product: squid
detection:
  selection:
    c-uri|contains:
      - 'pypi.org/simple/'
      - 'files.pythonhosted.org'
    src_ip|cidr:
      - '10.0.0.0/8'
      - '172.16.0.0/12'
      - '192.168.0.0/16'
  filter_approved:
    src_ip|cidr:
      - '10.0.5.0/24'   # developer workstations
  condition: selection and not filter_approved
fields:
  - src_ip
  - c-uri
  - cs-host
  - timestamp
falsepositives:
  - Developer workstations with direct PyPI access
  - Approved mirror sync jobs
level: high
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.t1199
```

### Dependency Confusion: Private Package Override

**Lab:** 1.2 Dependency Confusion | **Log Source:** Proxy logs, EDR

Detects a package with an internal namespace prefix being resolved from a public registry, and detects setup.py spawning network processes during installation.

```yaml
title: Dependency Confusion - Internal Package from Public Registry
id: b2c3d4e5-1201-4b6c-9d8e-f0a1b2c3d4e5
status: experimental
description: >
  A package matching internal naming conventions (wl-*, internal-*, company-*)
  was downloaded from public PyPI. Combined with a high version number,
  this is a strong dependency confusion indicator.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: proxy
  product: squid
detection:
  selection_source:
    c-uri|contains:
      - 'pypi.org/simple/'
      - 'files.pythonhosted.org'
  selection_internal_name:
    c-uri|re: '/(wl-|internal-|company-|corp-|priv-)[a-z0-9-]+'
  condition: selection_source and selection_internal_name
fields:
  - src_ip
  - c-uri
  - cs-host
  - timestamp
falsepositives:
  - Legitimate public packages that happen to start with internal prefixes
level: critical
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.execution
  - attack.t1059.006
```

```yaml
title: Dependency Confusion - setup.py Spawning Network Process
id: c3d4e5f6-1202-4c7d-ae9f-01b2c3d4e5f6
status: experimental
description: >
  pip install triggered setup.py which spawned a child process making
  outbound network connections. Legitimate packages rarely spawn
  curl, wget, or shell commands during installation.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: process_creation
  product: linux
detection:
  selection_parent:
    ParentImage|endswith: '/pip'
    ParentCommandLine|contains: 'install'
  selection_child:
    Image|endswith:
      - '/curl'
      - '/wget'
      - '/nc'
      - '/ncat'
    CommandLine|contains:
      - 'http://'
      - 'https://'
  condition: selection_parent and selection_child
fields:
  - ParentCommandLine
  - CommandLine
  - DestinationIp
  - User
falsepositives:
  - Packages with legitimate build-time downloads (e.g., grpcio, torch)
level: critical
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.execution
  - attack.t1059.006
  - attack.exfiltration
  - attack.t1020
```

### Typosquatting: Near-Homograph Package Installation

**Lab:** 1.3 Typosquatting | **Log Source:** EDR

Detects suspicious post-install behavior from package installation, such as reading environment variables during setup.py execution.

```yaml
title: Typosquatting - setup.py Reading Environment Variables
id: d4e5f6a7-1301-4d8e-bf0a-12c3d4e5f6a7
status: experimental
description: >
  setup.py or __init__.py accessed environment variables during package
  installation. Malicious typosquatted packages harvest credentials
  and tokens from the build environment via os.environ.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: process_creation
  product: linux
detection:
  selection:
    ParentImage|endswith:
      - '/pip'
      - '/pip3'
      - '/python'
      - '/python3'
    ParentCommandLine|contains: 'install'
  child_suspicious:
    CommandLine|contains:
      - 'os.environ'
      - 'printenv'
      - '/proc/self/environ'
      - 'env | '
  condition: selection and child_suspicious
fields:
  - ParentCommandLine
  - CommandLine
  - User
falsepositives:
  - Build tools that legitimately read environment for configuration
level: high
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.execution
  - attack.t1204.002
  - attack.defense_evasion
  - attack.t1036
```

### Manifest Confusion: Hidden Install Script Execution

**Lab:** 1.5 Manifest Confusion | **Log Source:** EDR

Detects npm packages executing install scripts that are not visible in registry metadata, indicating manifest confusion where the tarball contains hooks hidden from the API.

```yaml
title: Manifest Confusion - Hidden postinstall Script Execution
id: f6a7b8c9-1501-4f0a-d12b-34e5f6a7b8c9
status: experimental
description: >
  An npm package executed a postinstall, preinstall, or install script
  that was not listed in the registry API metadata. This is the signature
  of a manifest confusion attack where the tarball contains different
  metadata than the registry.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: process_creation
  product: linux
detection:
  selection_parent:
    ParentImage|endswith: '/node'
    ParentCommandLine|contains:
      - 'npm'
      - 'lifecycle'
  selection_script:
    CommandLine|contains:
      - 'postinstall'
      - 'preinstall'
  selection_network:
    Image|endswith:
      - '/curl'
      - '/wget'
      - '/node'
    DestinationPort:
      - 80
      - 443
  condition: selection_parent and (selection_script or selection_network)
fields:
  - ParentCommandLine
  - CommandLine
  - DestinationIp
  - DestinationPort
falsepositives:
  - Legitimate packages with install scripts (husky, esbuild, sharp, node-gyp)
level: medium
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.defense_evasion
  - attack.t1036.005
  - attack.execution
  - attack.t1574
```

</details>

<details open>
<summary>Tier 2: Build & CI/CD Security (EDR and DNS rules)</summary>

### Secret Exfiltration: DNS Tunneling from CI Runner

**Lab:** 2.4 Secret Exfiltration | **Log Source:** DNS

Detects CI runners making DNS queries with unusually long subdomains (>30 chars), indicating DNS-based exfiltration of secrets encoded in query labels.

```yaml
title: Secret Exfiltration - DNS Tunneling from CI Runner
id: f2a3b4c5-2402-4f6a-d78b-90e1f2a3b4c5
status: experimental
description: >
  CI runner made DNS queries with unusually long subdomains (>30 chars),
  indicating DNS-based exfiltration of secrets encoded in query labels.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: dns
  product: dns_server
detection:
  selection:
    query|re: '^[a-zA-Z0-9]{30,}\.'
    src_ip|cidr:
      - '10.0.0.0/8'
  filter_legitimate:
    query|endswith:
      - '.amazonaws.com'
      - '.cloudfront.net'
      - '.github.com'
  condition: selection and not filter_legitimate
fields:
  - src_ip
  - query
  - timestamp
falsepositives:
  - CDN hostnames with long subdomains
level: high
tags:
  - attack.exfiltration
  - attack.t1020
  - attack.command_and_control
  - attack.t1071.004
```

### Self-Hosted Runner Persistence

**Lab:** 2.5 Self-Hosted Runners | **Log Source:** EDR, host audit logs

Detects persistence mechanisms planted on self-hosted CI runners, such as cron jobs, shell profile modifications, or files written outside the workspace.

```yaml
title: Runner Persistence - File Written Outside Workspace
id: a3b4c5d6-2501-4a7b-e89c-01f2a3b4c5d6
status: experimental
description: >
  A CI job wrote files outside the designated workspace directory.
  This indicates a persistence attempt via tool cache, shell profiles,
  or cron job installation on a self-hosted runner.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: file_event
  product: linux
detection:
  selection_process:
    Image|contains: 'runner'
  selection_paths:
    TargetFilename|contains:
      - '/.bash_profile'
      - '/.bashrc'
      - '/.profile'
      - '/cron.d/'
      - '/crontab'
      - '/_work/_tool/.hidden'
      - '/systemd/system/'
  condition: selection_process and selection_paths
fields:
  - Image
  - TargetFilename
  - User
  - timestamp
falsepositives:
  - Runner setup scripts that configure the tool cache
level: critical
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.persistence
  - attack.t1053
```

</details>

<details open>
<summary>Tier 3: Container Security (Kubernetes audit log rules)</summary>

### Registry Confusion: Unqualified Image Name Resolution

**Lab:** 3.4 Registry Confusion | **Log Source:** Kubernetes audit logs

Detects container images being pulled from registries not on the approved list, or using unqualified names that resolve to Docker Hub by default.

```yaml
title: Registry Confusion - Pull from Unapproved Registry
id: b0c1d2e3-3401-4b4c-f56d-78a9b0c1d2e3
status: experimental
description: >
  A container image was pulled from a registry not in the approved
  list. Unqualified image names default to docker.io, which an
  attacker can exploit by registering matching image names.
author: WeakLink Labs
date: 2026/04/07
logsource:
  product: kubernetes
  service: audit
detection:
  selection:
    verb: 'create'
    objectRef.resource: 'pods'
  pull_event:
    requestObject.spec.containers.image|startswith:
      - 'docker.io/'
  filter_approved:
    requestObject.spec.containers.image|startswith:
      - 'registry.internal.corp/'
      - 'gcr.io/'
      - 'registry.k8s.io/'
  condition: selection and pull_event and not filter_approved
fields:
  - requestObject.spec.containers.image
  - user.username
  - objectRef.namespace
falsepositives:
  - Development namespaces with relaxed registry policies
level: high
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.defense_evasion
  - attack.t1036.005
```

</details>

<details open>
<summary>Tier 4: SBOM & Signing (Kubernetes audit log rules)</summary>

### Signature Bypass: Unsigned Image Deployed

**Lab:** 4.5 Signature Bypass | **Log Source:** Kubernetes audit logs

Detects deployment of container images that lack a valid cryptographic signature or where the signature was created by an untrusted key.

```yaml
title: Signature Bypass - Unsigned Image Deployment Attempt
id: f4a5b6c7-4501-4f8a-d90b-12e3f4a5b6c7
status: experimental
description: >
  A container image was deployed or attempted deployment without a
  valid cosign/notation signature. This bypasses the integrity
  verification that ties images to trusted build pipelines.
author: WeakLink Labs
date: 2026/04/07
logsource:
  product: kubernetes
  service: audit
detection:
  selection:
    verb: 'create'
    objectRef.resource: 'pods'
  signature_missing:
    annotations|not_contains: 'cosign.sigstore.dev'
    responseStatus.code: 403
    responseStatus.reason|contains: 'signature'
  condition: selection and signature_missing
fields:
  - requestObject.spec.containers.image
  - user.username
  - objectRef.namespace
  - responseStatus.reason
falsepositives:
  - Development namespaces exempt from signing requirements
level: high
tags:
  - attack.defense_evasion
  - attack.t1553
```

</details>

<details open>
<summary>Tier 5: IaC Supply Chain</summary>

### Helm Resolution: Chart Pulled from Untrusted Repository

**Lab:** 5.1 Helm Resolution | **Log Source:** Proxy logs

Detects Helm pulling charts from public repositories when policy requires using only the private chart registry.

```yaml
title: Helm Chart - Pull from Untrusted Repository
id: c7d8e9f0-5101-4c1d-a23e-45b6c7d8e9f0
status: experimental
description: >
  Helm resolved and pulled a chart from a public repository not on
  the approved list. This enables dependency confusion at the
  chart level where an attacker publishes a higher-version chart
  to a public repo.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: proxy
  product: squid
detection:
  selection:
    c-uri|contains:
      - '/charts/'
      - '/index.yaml'
    cs-method: 'GET'
  filter_approved:
    cs-host|contains:
      - 'charts.internal.corp'
      - 'harbor.internal.corp'
  condition: selection and not filter_approved
fields:
  - src_ip
  - cs-host
  - c-uri
  - timestamp
falsepositives:
  - Approved public chart repositories (add to filter)
level: high
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
```

### Helm Poisoning: Post-Install Hook Creating RBAC Resources

**Lab:** 5.2 Helm Poisoning | **Log Source:** Kubernetes audit logs

Detects Helm post-install hooks that create ClusterRoleBindings or other RBAC resources, which is the signature of a privilege escalation payload in a poisoned chart.

```yaml
title: Helm Poisoning - Hook Creating ClusterRoleBinding
id: d8e9f0a1-5201-4d2e-b34f-56c7d8e9f0a1
status: experimental
description: >
  A Kubernetes Job with helm.sh/hook annotations created a
  ClusterRoleBinding. Legitimate charts rarely create cluster-wide
  RBAC resources from hooks. This is the signature of a privilege
  escalation payload in a poisoned Helm chart.
author: WeakLink Labs
date: 2026/04/07
logsource:
  product: kubernetes
  service: audit
detection:
  selection_resource:
    verb: 'create'
    objectRef.resource: 'clusterrolebindings'
  selection_source:
    user.username|contains: 'system:serviceaccount'
    sourceIPs|cidr:
      - '10.0.0.0/8'
  hook_job:
    requestObject.metadata.annotations|contains: 'helm.sh/hook'
  condition: selection_resource and (selection_source or hook_job)
fields:
  - requestObject.metadata.name
  - requestObject.roleRef.name
  - user.username
  - objectRef.namespace
falsepositives:
  - Legitimate charts that require cluster-admin (cert-manager, ingress controllers)
level: critical
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.privilege_escalation
  - attack.t1078
```

### Terraform Module Attacks: Credential Exfiltration via local-exec

**Lab:** 5.3 Terraform Modules | **Log Source:** EDR

Detects `terraform apply` spawning child processes that make outbound network connections, indicating a malicious `local-exec` provisioner exfiltrating credentials.

```yaml
title: Terraform Module Attack - local-exec Network Exfiltration
id: e9f0a1b2-5301-4e3f-c45a-67d8e9f0a1b2
status: experimental
description: >
  Terraform apply spawned a child process (curl, wget, nc) that made
  outbound network connections. Malicious Terraform modules use
  local-exec provisioners to exfiltrate cloud credentials from
  the CI environment.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: process_creation
  product: linux
detection:
  selection_parent:
    ParentImage|endswith: '/terraform'
    ParentCommandLine|contains: 'apply'
  selection_child:
    Image|endswith:
      - '/curl'
      - '/wget'
      - '/nc'
      - '/ncat'
      - '/python'
      - '/python3'
  condition: selection_parent and selection_child
fields:
  - ParentCommandLine
  - CommandLine
  - DestinationIp
  - User
falsepositives:
  - Terraform provisioners that legitimately call APIs (e.g., health checks)
level: critical
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.execution
  - attack.t1059
  - attack.exfiltration
  - attack.t1020
```

### Ansible Galaxy: Malicious Role Installing SSH Backdoor

**Lab:** 5.4 Ansible Galaxy | **Log Source:** Host audit logs

Detects SSH authorized_keys modifications following an Ansible playbook run, indicating a malicious role planted a backdoor SSH key.

```yaml
title: Ansible Galaxy - Unauthorized SSH Key Planted by Role
id: f0a1b2c3-5401-4f4a-d56b-78e9f0a1b2c3
status: experimental
description: >
  SSH authorized_keys was modified during or immediately after an
  Ansible playbook run. A malicious Galaxy role can plant SSH
  keys using the authorized_key module while performing its
  stated purpose.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: file_event
  product: linux
detection:
  selection:
    TargetFilename|endswith: '/authorized_keys'
    EventType: 'FileWrite'
  timeframe_correlation:
    ParentImage|contains:
      - 'ansible'
      - 'python'
    ParentCommandLine|contains: 'playbook'
  condition: selection and timeframe_correlation
fields:
  - TargetFilename
  - ParentCommandLine
  - User
  - timestamp
falsepositives:
  - Ansible roles that legitimately manage SSH keys (user management roles)
level: high
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.persistence
  - attack.t1098.004
```

### Admission Controller Bypass: Privileged Pod in Exempt Namespace

**Lab:** 5.5 Admission Bypass | **Log Source:** Kubernetes audit logs

Detects creation of privileged containers in namespaces typically exempt from admission controller policies.

```yaml
title: Admission Bypass - Privileged Pod in kube-system
id: a1b2c3d4-5501-4a5b-e67c-89f0a1b2c3d4
status: experimental
description: >
  A privileged container was created in kube-system or another
  namespace exempt from admission controller policies. Attackers
  deploy workloads in exempt namespaces to bypass OPA/Gatekeeper
  and Kyverno policies.
author: WeakLink Labs
date: 2026/04/07
logsource:
  product: kubernetes
  service: audit
detection:
  selection:
    verb: 'create'
    objectRef.resource: 'pods'
    objectRef.namespace:
      - 'kube-system'
      - 'kube-public'
      - 'default'
  privileged:
    requestObject.spec.containers.securityContext.privileged: true
  filter_system:
    user.username|startswith:
      - 'system:node:'
      - 'system:serviceaccount:kube-system:'
  condition: selection and privileged and not filter_system
fields:
  - requestObject.metadata.name
  - requestObject.spec.containers.image
  - user.username
  - objectRef.namespace
falsepositives:
  - System components that require privileged access (CNI plugins, monitoring agents)
level: critical
tags:
  - attack.privilege_escalation
  - attack.t1611
  - attack.defense_evasion
  - attack.t1562
```

</details>

<details open>
<summary>Tier 6: Case Studies & Frontier Attacks</summary>

### ML Model Supply Chain: Malicious Deserialization

**Lab:** 6.1 ML Model Supply Chain | **Log Source:** EDR

Detects Python processes spawning unexpected child processes during model loading, indicating a deserialization attack via unsafe model formats.

```yaml
title: ML Model Attack - Code Execution During Model Load
id: b2c3d4e5-6101-4b6c-f78d-90a1b2c3d4e5
status: experimental
description: >
  A Python process spawned unexpected child processes (shell, curl,
  wget) during model deserialization. Unsafe model loading functions
  execute arbitrary code embedded in model files.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: process_creation
  product: linux
detection:
  selection_parent:
    ParentImage|endswith:
      - '/python'
      - '/python3'
    ParentCommandLine|contains:
      - 'load_model'
      - 'torch.load'
      - 'joblib.load'
  selection_child:
    Image|endswith:
      - '/sh'
      - '/bash'
      - '/curl'
      - '/wget'
      - '/nc'
  condition: selection_parent and selection_child
fields:
  - ParentCommandLine
  - CommandLine
  - DestinationIp
  - User
falsepositives:
  - ML frameworks that spawn subprocesses for GPU initialization
level: critical
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.execution
  - attack.t1059.006
  - attack.defense_evasion
  - attack.t1480
```

### Dataset Poisoning: Training Data Integrity Drift

**Lab:** 6.2 Dataset Poisoning | **Log Source:** File integrity monitoring

Detects modifications to training datasets after download or unexpected changes in label distribution.

```yaml
title: Dataset Poisoning - Training Data Modified After Download
id: c3d4e5f6-6201-4c7d-a89e-01b2c3d4e5f6
status: experimental
description: >
  A training dataset file was modified after its initial download
  and integrity verification. Dataset poisoning attacks modify
  training data to inject backdoor triggers.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: file_event
  product: linux
detection:
  selection:
    TargetFilename|contains:
      - '/datasets/'
      - '/training_data/'
      - '/data/train'
    EventType: 'FileWrite'
  filter_download:
    Image|endswith:
      - '/curl'
      - '/wget'
      - '/python'
  filter_expected:
    User:
      - 'data-pipeline'
      - 'ml-train'
  condition: selection and not filter_download and not filter_expected
fields:
  - TargetFilename
  - Image
  - User
  - timestamp
falsepositives:
  - Data preprocessing pipelines that transform data in place
level: high
tags:
  - attack.impact
  - attack.t1565.001
  - attack.supply_chain_compromise
  - attack.t1195.002
```

### SolarWinds (SUNBURST): C2 Domain Detection

**Lab:** 6.6 SolarWinds | **Log Source:** DNS logs

Detects DNS queries to known SUNBURST C2 domains.

```yaml
title: SolarWinds SUNBURST - C2 DNS Communication
id: a7b8c9d0-6601-4a1b-e23c-45f6a7b8c9d0
status: experimental
description: >
  DNS queries to avsvmcloud.com, the SUNBURST C2 domain, or build
  artifacts that do not match expected hashes from the same source
  code. Build compromise attacks produce different binaries from
  identical source.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: dns
  product: dns_server
detection:
  selection_sunburst:
    query|endswith: '.avsvmcloud.com'
  condition: selection_sunburst
fields:
  - src_ip
  - query
  - timestamp
falsepositives:
  - None. This domain is confirmed C2 infrastructure.
level: critical
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.command_and_control
  - attack.t1071.004
```

### Codecov: CI Script Tampering and Env Exfiltration

**Lab:** 6.7 Codecov | **Log Source:** EDR

Detects CI runners downloading scripts via curl/wget and piping them directly to a shell, which is the Codecov attack pattern.

```yaml
title: Codecov-Style Attack - CI Script Hash Mismatch
id: c9d0e1f2-6701-4c3d-a45e-67b8c9d0e1f2
status: experimental
description: >
  A CI pipeline downloaded a script via curl/wget and the file hash
  does not match the expected value. This is the Codecov attack
  pattern where the bash uploader was modified to exfiltrate secrets.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: process_creation
  product: linux
detection:
  selection_download:
    CommandLine|contains:
      - 'curl -s'
      - 'curl -fsSL'
      - 'wget -q'
    CommandLine|contains:
      - '| bash'
      - '| sh'
  condition: selection_download
fields:
  - CommandLine
  - ParentCommandLine
  - DestinationIp
  - User
falsepositives:
  - Legitimate CI setup scripts (should be pinned by hash)
level: high
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.execution
  - attack.t1059.004
  - attack.exfiltration
  - attack.t1020
```

### Log4Shell: JNDI Lookup Exploitation

**Lab:** 6.9 Log4Shell | **Log Source:** Web server logs, EDR

Detects JNDI lookup patterns in application input and outbound LDAP connections from Java processes, indicating Log4Shell exploitation.

```yaml
title: Log4Shell - JNDI Lookup Pattern in Input
id: e1f2a3b4-6901-4e5f-c67a-89d0e1f2a3b4
status: experimental
description: >
  Application input contains JNDI lookup patterns (${jndi:ldap://,
  ${jndi:rmi://, ${jndi:dns://) including common obfuscation
  techniques. This is the primary exploitation vector for
  CVE-2021-44228.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: webserver
  product: apache
detection:
  selection:
    cs-uri|contains:
      - '${jndi:'
      - '${${lower:j}ndi:'
      - '${${::-j}${::-n}${::-d}${::-i}:'
    cs-User-Agent|contains:
      - '${jndi:'
  selection_headers:
    cs-Referer|contains: '${jndi:'
    X-Forwarded-For|contains: '${jndi:'
  condition: selection or selection_headers
fields:
  - cs-uri
  - cs-User-Agent
  - c-ip
  - timestamp
falsepositives:
  - Security scanners testing for Log4Shell
level: critical
tags:
  - attack.initial_access
  - attack.t1190
  - attack.execution
  - attack.t1059
```

```yaml
title: Log4Shell - Outbound LDAP from Java Process
id: f2a3b4c5-6902-4f6a-d78b-90e1f2a3b4c5
status: experimental
description: >
  A Java process initiated an outbound LDAP connection to a non-internal
  server. This indicates successful Log4Shell exploitation where the
  JNDI lookup connected to an attacker-controlled LDAP server.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: network_connection
  product: linux
detection:
  selection:
    Image|endswith: '/java'
    DestinationPort:
      - 389
      - 636
      - 1099
      - 1389
  filter_internal:
    DestinationIp|cidr:
      - '10.0.0.0/8'
      - '172.16.0.0/12'
      - '192.168.0.0/16'
  condition: selection and not filter_internal
fields:
  - Image
  - DestinationIp
  - DestinationPort
  - User
  - timestamp
falsepositives:
  - Applications that legitimately connect to external LDAP servers
level: critical
tags:
  - attack.initial_access
  - attack.t1190
  - attack.execution
  - attack.t1203
```

### Equifax (CVE-2017-5638): Struts OGNL Injection

**Lab:** 6.10 Equifax | **Log Source:** Web server logs

Detects OGNL expression patterns in HTTP Content-Type headers, the exploitation vector for the Apache Struts vulnerability.

```yaml
title: Equifax-Style - OGNL Expression in Content-Type Header
id: a3b4c5d6-6100-4a7b-e89c-01f2a3b4c5d6
status: experimental
description: >
  An HTTP request contains OGNL expression patterns in the Content-Type
  header, the signature of CVE-2017-5638 exploitation. This was the
  vector used in the Equifax breach.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: webserver
  product: apache
detection:
  selection:
    Content-Type|contains:
      - 'OgnlContext'
      - '#cmd='
      - 'Runtime.getRuntime()'
      - 'ProcessBuilder'
      - 'multipart/form-data'
    Content-Type|re: '#\w+\s*=\s*@'
  condition: selection
fields:
  - c-ip
  - cs-uri
  - Content-Type
  - timestamp
falsepositives:
  - None for OGNL patterns in Content-Type headers
level: critical
tags:
  - attack.initial_access
  - attack.t1190
  - attack.execution
  - attack.t1059
```

</details>

<details open>
<summary>Cloud-Specific Example</summary>

These cloud scenarios are reference detections in the library. They are not current WeakLink Labs tiers.

### Cloud Marketplace Poisoning: Backdoored AMI Deployment

**Reference Scenario:** Marketplace Poisoning | **Log Source:** CloudTrail

Detects EC2 instances launched from AMIs by unknown publishers, with subsequent outbound connections to attacker infrastructure.

```yaml
title: Cloud Marketplace Poisoning - AMI from Unknown Publisher
id: b4c5d6e7-9101-4b8c-f90d-12a3b4c5d6e7
status: experimental
description: >
  An EC2 instance was launched from an AMI whose publisher is not on
  the approved list. Cloud marketplace images can contain pre-installed
  backdoors, SSH keys, and cryptocurrency miners.
author: WeakLink Labs
date: 2026/04/07
logsource:
  product: aws
  service: cloudtrail
detection:
  selection:
    eventName: 'RunInstances'
  filter_approved:
    requestParameters.instancesSet.items.imageId|startswith:
      - 'ami-approved-'
    responseElements.instancesSet.items.imageId|in_approved_list: true
  condition: selection and not filter_approved
fields:
  - requestParameters.instancesSet.items.imageId
  - userIdentity.arn
  - sourceIPAddress
  - awsRegion
falsepositives:
  - New AMIs being evaluated in sandbox accounts
level: high
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.persistence
  - attack.t1525
  - attack.initial_access
  - attack.t1078.004
```

### Serverless Supply Chain: Malicious Lambda Layer

**Reference Scenario:** Serverless Supply Chain | **Log Source:** CloudTrail

Detects Lambda function configuration changes that add layers from untrusted sources, or Lambda functions with unexpected execution duration increases.

```yaml
title: Serverless Attack - Lambda Layer from Untrusted Source
id: c5d6e7f8-9201-4c9d-a01e-23b4c5d6e7f8
status: experimental
description: >
  A Lambda function configuration was updated to include a layer from
  an account not on the approved list. Malicious layers can inject
  code that executes on every invocation without modifying the
  function source.
author: WeakLink Labs
date: 2026/04/07
logsource:
  product: aws
  service: cloudtrail
detection:
  selection:
    eventName:
      - 'UpdateFunctionConfiguration20150331v2'
      - 'CreateFunction20150331'
    requestParameters.layers|contains: 'arn:aws:lambda:'
  filter_approved:
    requestParameters.layers|contains:
      - ':123456789012:'   # your account
      - ':aws:'            # AWS-managed layers
  condition: selection and not filter_approved
fields:
  - requestParameters.functionName
  - requestParameters.layers
  - userIdentity.arn
  - sourceIPAddress
falsepositives:
  - Approved third-party layers (add account IDs to filter)
level: high
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.resource_development
  - attack.t1583.007
  - attack.execution
  - attack.t1059
```

### Cloud CI/CD Attacks: CodeBuild Privilege Escalation

**Reference Scenario:** Cloud CI/CD Attacks | **Log Source:** CloudTrail

Detects CodeBuild projects assuming IAM roles outside their intended scope or accessing production SSM parameters.

```yaml
title: Cloud CI/CD - CodeBuild Accessing Production Secrets
id: d6e7f8a9-9301-4d0e-b12f-34c5d6e7f8a9
status: experimental
description: >
  An AWS CodeBuild project accessed SSM Parameter Store parameters
  outside its designated path, or assumed an IAM role not intended
  for build workloads. This indicates privilege escalation from
  a compromised build environment.
author: WeakLink Labs
date: 2026/04/07
logsource:
  product: aws
  service: cloudtrail
detection:
  selection_ssm:
    eventName: 'GetParameter'
    requestParameters.name|startswith: '/prod/'
    userIdentity.arn|contains: 'codebuild'
  selection_escalation:
    eventName: 'AssumeRole'
    userIdentity.arn|contains: 'codebuild'
    requestParameters.roleArn|not_contains: 'codebuild'
  condition: selection_ssm or selection_escalation
fields:
  - eventName
  - requestParameters.name
  - requestParameters.roleArn
  - userIdentity.arn
  - sourceIPAddress
falsepositives:
  - Build pipelines that legitimately deploy to production (should use separate roles)
level: critical
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.credential_access
  - attack.t1552.001
  - attack.privilege_escalation
  - attack.t1078
```

### IAM Chain Abuse: Rapid Cross-Account AssumeRole

**Reference Scenario:** IAM Chain Abuse | **Log Source:** CloudTrail

Detects rapid cross-account AssumeRole chains that traverse multiple accounts in quick succession, indicating stolen credentials being used to traverse trust relationships.

```yaml
title: IAM Chain Abuse - Rapid Cross-Account Role Traversal
id: e7f8a9b0-9401-4e1f-c23a-45d6e7f8a9b0
status: experimental
description: >
  Multiple cross-account AssumeRole calls occurred within a short
  timeframe from the same source, traversing different AWS accounts.
  Legitimate cross-account access follows predictable patterns.
  Rapid traversal across 3+ accounts indicates credential abuse.
author: WeakLink Labs
date: 2026/04/07
logsource:
  product: aws
  service: cloudtrail
detection:
  selection:
    eventName: 'AssumeRole'
    resources.accountId|different_from: userIdentity.accountId
  timeframe: 5m
  condition: selection | count(resources.accountId) by userIdentity.arn > 2
fields:
  - userIdentity.arn
  - requestParameters.roleArn
  - resources.accountId
  - sourceIPAddress
  - eventTime
falsepositives:
  - Infrastructure-as-code tools that deploy across multiple accounts
  - Centralized monitoring systems
level: critical
tags:
  - attack.lateral_movement
  - attack.t1078.004
  - attack.credential_access
  - attack.t1550.001
  - attack.supply_chain_compromise
  - attack.t1195.002
```

</details>

---

## Detection Logic Patterns

> **Detection Logic, Not Production Sigma**
>
> The rules below describe detection patterns for CI/CD, VCS, container registry, SBOM, and other specialized telemetry. They use custom log source definitions that require platform-specific parsing and indexing before use. Adapt the logic to your SIEM's native query language (KQL, SPL, Lucene) and your organization's log pipeline.
<details open>
<summary>Tier 1: Package Security (VCS and CI patterns)</summary>

### Lockfile Injection: Lockfile-Only PR Modification

**Lab:** 1.4 Lockfile Injection | **Log Source:** GitHub audit logs, VCS webhooks

Detects pull requests that modify only lockfiles without corresponding manifest changes, a signature of lockfile injection attacks.

```yaml
title: Lockfile Injection - Lockfile Modified Without Manifest Change
id: e5f6a7b8-1401-4e9f-c01b-23d4e5f6a7b8
status: experimental
description: >
  A pull request modified lockfiles (requirements.txt, package-lock.json,
  yarn.lock) but did not modify any manifest files. Normal dependency
  updates always touch both. Lockfile-only changes from human accounts
  are a high-confidence lockfile injection indicator.
author: WeakLink Labs
date: 2026/04/07
logsource:
  product: github
  service: audit
detection:
  selection_lockfile:
    action: 'pull_request.opened'
    files_changed|contains:
      - 'requirements.txt'
      - 'package-lock.json'
      - 'yarn.lock'
      - 'Pipfile.lock'
      - 'poetry.lock'
      - 'pnpm-lock.yaml'
  filter_manifest:
    files_changed|contains:
      - 'requirements.in'
      - 'package.json'
      - 'Pipfile'
      - 'pyproject.toml'
      - 'setup.py'
      - 'setup.cfg'
  filter_bot:
    actor|contains:
      - 'dependabot'
      - 'renovate'
      - '[bot]'
  condition: selection_lockfile and not filter_manifest and not filter_bot
fields:
  - actor
  - repository
  - files_changed
  - timestamp
falsepositives:
  - Manual lockfile regeneration (should still be reviewed)
level: high
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.initial_access
  - attack.t1566.001
  - attack.defense_evasion
  - attack.t1553
```

### Phantom Dependencies: Undeclared Package Import

**Lab:** 1.6 Phantom Dependencies | **Log Source:** CI pipeline logs, package manager logs

Detects packages installed at suspiciously high version numbers, which indicates an attacker published a malicious version to replace a transitive dependency relied on implicitly.

```yaml
title: Phantom Dependency - Suspiciously High Package Version
id: a7b8c9d0-1601-4a1b-e23c-45f6a7b8c9d0
status: experimental
description: >
  A package was installed at a major version above 50, which is a
  classic indicator of dependency confusion or phantom dependency
  exploitation. Attackers use high version numbers to win resolution.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: process_creation
  product: linux
detection:
  selection:
    CommandLine|contains: 'npm install'
  output_indicator:
    Stdout|re: 'added.*@(5[0-9]|[6-9][0-9]|[0-9]{3,})\.'
  condition: selection and output_indicator
fields:
  - CommandLine
  - Stdout
  - User
falsepositives:
  - Legitimate packages with very high major versions (rare)
level: high
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.t1195.001
  - attack.execution
  - attack.t1574.002
```

</details>

<details open>
<summary>Tier 2: Build & CI/CD Security (VCS and CI patterns)</summary>

### Direct PPE: CI Config Modified in Pull Request

**Lab:** 2.2 Direct PPE | **Log Source:** GitHub audit logs, CI workflow logs

Detects pull requests that modify CI pipeline configuration files. When combined with secret access or outbound network connections, this is a direct Poisoned Pipeline Execution attack.

```yaml
title: Direct PPE - CI Config Modified in Pull Request
id: b8c9d0e1-2201-4b2c-f34d-56a7b8c9d0e1
status: experimental
description: >
  A pull request modified CI/CD configuration files (.github/workflows/,
  .gitlab-ci.yml, Jenkinsfile). If the PR is from an external contributor
  and the workflow has secret access, this is a direct PPE vector.
author: WeakLink Labs
date: 2026/04/07
logsource:
  product: github
  service: audit
detection:
  selection:
    action: 'pull_request.opened'
    files_changed|contains:
      - '.github/workflows/'
      - '.gitlab-ci.yml'
      - 'Jenkinsfile'
      - '.circleci/'
      - '.travis.yml'
  filter_trusted:
    actor_association: 'MEMBER'
  condition: selection and not filter_trusted
fields:
  - actor
  - repository
  - files_changed
  - actor_association
falsepositives:
  - External contributors legitimately improving CI configs (still requires review)
level: high
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.execution
  - attack.t1059
```

```yaml
title: Direct PPE - PR Build Accessing Production Secrets
id: c9d0e1f2-2202-4c3d-a45e-67b8c9d0e1f2
status: experimental
description: >
  A CI build triggered by a pull_request event accessed secrets typically
  reserved for push-to-main builds. PR builds should never have access
  to deployment credentials.
author: WeakLink Labs
date: 2026/04/07
logsource:
  product: github
  service: audit
detection:
  selection_trigger:
    event_type: 'pull_request'
  selection_secret_access:
    action|contains:
      - 'secret.read'
      - 'GetSecret'
    secret_name|contains:
      - 'DEPLOY'
      - 'PROD'
      - 'AWS_'
      - 'GCP_'
      - 'AZURE_'
  condition: selection_trigger and selection_secret_access
fields:
  - workflow_name
  - secret_name
  - actor
  - repository
falsepositives:
  - Misconfigured workflows that expose secrets to PR builds
level: critical
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.execution
  - attack.t1059
```

### Indirect PPE: Build Script Modification with Network Commands

**Lab:** 2.3 Indirect PPE | **Log Source:** VCS webhooks

Detects modifications to files executed by CI (Makefiles, shell scripts) that introduce network commands, without touching the CI config itself.

```yaml
title: Indirect PPE - Network Commands Added to CI-Referenced Files
id: d0e1f2a3-2301-4d4e-b56f-78c9d0e1f2a3
status: experimental
description: >
  A PR modified files referenced by CI pipelines (Makefile, scripts/,
  Dockerfile) and added network commands. The CI config itself was not
  changed, making this an indirect PPE attack vector.
author: WeakLink Labs
date: 2026/04/07
logsource:
  product: github
  service: audit
detection:
  selection_files:
    action: 'pull_request.opened'
    files_changed|contains:
      - 'Makefile'
      - 'scripts/'
      - 'Dockerfile'
      - '.sh'
  selection_content:
    diff_content|contains:
      - 'curl '
      - 'wget '
      - 'nc '
      - 'ncat '
      - 'base64 '
      - '/dev/tcp/'
  filter_ci_config:
    files_changed|contains:
      - '.github/workflows/'
      - '.gitlab-ci.yml'
  condition: selection_files and selection_content and not filter_ci_config
fields:
  - actor
  - repository
  - files_changed
falsepositives:
  - Legitimate build script updates that add download steps
level: medium
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.execution
  - attack.t1059.004
```

### Secret Exfiltration: Credential Patterns in Build Artifacts

**Lab:** 2.4 Secret Exfiltration | **Log Source:** CI artifact storage, build logs

Detects secret patterns (API keys, tokens) appearing in build artifacts or logs, indicating credential leakage from CI pipelines.

```yaml
title: Secret Exfiltration - Credential Pattern in Build Artifact
id: e1f2a3b4-2401-4e5f-c67a-89d0e1f2a3b4
status: experimental
description: >
  Build artifacts or CI logs contain strings matching known secret
  patterns (GitHub tokens, AWS keys, generic API keys). Secrets
  should never appear in build output.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: application
  product: ci_runner
detection:
  selection:
    log_content|re: '(ghp_[a-zA-Z0-9]{36}|AKIA[A-Z0-9]{16}|sk-[a-zA-Z0-9]{48}|-----BEGIN (RSA |EC )?PRIVATE KEY)'
  condition: selection
fields:
  - workflow_name
  - step_name
  - log_content
  - actor
falsepositives:
  - Secret scanning test patterns in documentation
level: critical
tags:
  - attack.exfiltration
  - attack.t1020
  - attack.credential_access
  - attack.t1552.001
```

### Actions Injection: Shell Metacharacters in Event Metadata

**Lab:** 2.6 Actions Injection | **Log Source:** GitHub webhooks, CI workflow logs

Detects issue titles, PR titles, or comment bodies containing shell injection patterns that could exploit `${{ github.event.* }}` expression interpolation.

```yaml
title: Actions Injection - Shell Metacharacters in Issue Title
id: b4c5d6e7-2601-4b8c-f90d-12a3b4c5d6e7
status: experimental
description: >
  An issue or PR was created with a title containing shell metacharacters
  ($(), backticks, &&, ||) that could exploit GitHub Actions expression
  injection if the workflow interpolates event metadata in run: blocks.
author: WeakLink Labs
date: 2026/04/07
logsource:
  product: github
  service: audit
detection:
  selection:
    action|contains:
      - 'issues.opened'
      - 'issue_comment.created'
      - 'pull_request.opened'
  injection_patterns:
    title|re: '(\$\(|`[^`]+`|&&\s*(curl|wget|nc|bash)|;\s*(curl|wget|nc|bash)|\|\|)'
  condition: selection and injection_patterns
fields:
  - actor
  - title
  - repository
  - action
falsepositives:
  - Technical issues discussing shell syntax in titles
level: high
tags:
  - attack.execution
  - attack.t1059
  - attack.initial_access
  - attack.t1190
```

### Build Cache Poisoning: Cache Key Collision

**Lab:** 2.7 Build Cache Poisoning | **Log Source:** CI workflow logs

Detects cache restore events using prefix-match fallback keys on the default branch, which could indicate a poisoned cache entry created by a PR.

```yaml
title: Build Cache Poisoning - Prefix Match Restore on Default Branch
id: c5d6e7f8-2701-4c9d-a01e-23b4c5d6e7f8
status: experimental
description: >
  A CI build on the default branch restored a cache using prefix
  matching (restore-keys) instead of an exact key match. A PR branch
  may have poisoned the cache with malicious packages.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: application
  product: ci_runner
detection:
  selection_branch:
    branch:
      - 'main'
      - 'master'
  selection_cache:
    log_content|contains: 'Cache restored from key:'
  filter_exact:
    log_content|contains: 'exact match'
  condition: selection_branch and selection_cache and not filter_exact
fields:
  - workflow_name
  - branch
  - cache_key
  - log_content
falsepositives:
  - First build after lockfile change (cache miss with fallback)
level: medium
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.execution
  - attack.t1574
```

### Workflow Run Attacks: Artifact Execution in Privileged Context

**Lab:** 2.8 Workflow Run Attacks | **Log Source:** GitHub audit logs, CI workflow logs

Detects `workflow_run` workflows that download artifacts and execute them, which enables privilege escalation from PR context to default branch context.

```yaml
title: Workflow Run Attack - Artifact Downloaded and Executed
id: d6e7f8a9-2801-4d0e-b12f-34c5d6e7f8a9
status: experimental
description: >
  A workflow_run workflow downloaded an artifact from a triggering
  workflow and subsequently executed a script or binary. This enables
  an attacker to escalate from PR permissions to default branch
  permissions with full secret access.
author: WeakLink Labs
date: 2026/04/07
logsource:
  product: github
  service: audit
detection:
  selection_trigger:
    event_type: 'workflow_run'
  selection_artifact:
    action|contains: 'download-artifact'
  selection_execute:
    action|contains:
      - 'bash'
      - 'sh '
      - 'python'
      - 'node'
  condition: selection_trigger and selection_artifact and selection_execute
fields:
  - workflow_name
  - triggering_workflow
  - actor
  - repository
falsepositives:
  - Legitimate deployment workflows that process build artifacts (review carefully)
level: high
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.execution
  - attack.t1574
```

</details>

<details open>
<summary>Tier 3: Container Security (registry and scanner patterns)</summary>

### Image Internals: Hidden Content in Layers

**Lab:** 3.1 Image Internals | **Log Source:** Container registry logs, CI build logs

Detects container images where files were added and then deleted in subsequent layers, leaving hidden content extractable from intermediate layers.

```yaml
title: Container Image - Add-Then-Delete Layer Pattern
id: e7f8a9b0-3101-4e1f-c23a-45d6e7f8a9b0
status: experimental
description: >
  A container image contains layers where files are added (COPY/ADD)
  and then removed (RUN rm) in subsequent layers. The data persists
  in intermediate layers and can be extracted with docker save.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: application
  product: docker
detection:
  selection:
    event_type: 'image.build'
  add_then_delete:
    history|contains|all:
      - 'COPY'
      - 'rm -rf'
  condition: selection and add_then_delete
fields:
  - image_name
  - image_tag
  - layer_count
  - history
falsepositives:
  - Build stages that clean up build tools (should use multi-stage instead)
level: medium
tags:
  - attack.persistence
  - attack.t1525
  - attack.defense_evasion
  - attack.t1036
```

### Tag Mutability: Registry Tag Overwrite

**Lab:** 3.2 Tag Mutability | **Log Source:** Container registry audit logs

Detects a container image tag being pushed when the tag already exists with a different digest, indicating the image content was replaced.

```yaml
title: Container Registry - Tag Overwrite Detected
id: f8a9b0c1-3201-4f2a-d34b-56e7f8a9b0c1
status: experimental
description: >
  A container image tag was pushed to the registry where the same tag
  already existed with a different digest. This replaces the previous
  image silently. Kubernetes deployments using imagePullPolicy: Always
  will pull the attacker's replacement on next restart.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: application
  product: container_registry
detection:
  selection:
    event_type: 'manifest.put'
    tag_exists: true
  tag_changed:
    new_digest|not_equals: previous_digest
  condition: selection and tag_changed
fields:
  - repository
  - tag
  - new_digest
  - previous_digest
  - actor
  - source_ip
falsepositives:
  - Mutable tags like "latest" being intentionally updated
  - CI/CD pipelines that rebuild and repush with the same tag
level: high
tags:
  - attack.persistence
  - attack.t1525
  - attack.execution
  - attack.t1610
```

### Base Image Poisoning: Unauthorized Base Image Push

**Lab:** 3.3 Base Image Poisoning | **Log Source:** Container registry audit logs

Detects pushes to base image repositories from non-CI sources, indicating an unauthorized modification of shared base images.

```yaml
title: Base Image Poisoning - Push from Non-CI Source
id: a9b0c1d2-3301-4a3b-e45c-67f8a9b0c1d2
status: experimental
description: >
  A base image repository received a push from an identity or IP
  that is not the approved CI pipeline. Base images should only
  be updated through the designated build process.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: application
  product: container_registry
detection:
  selection_repo:
    repository|contains:
      - 'base-'
      - '-base'
      - '/base/'
      - 'python-base'
      - 'node-base'
      - 'golang-base'
  selection_push:
    event_type: 'manifest.put'
  filter_ci:
    actor|contains:
      - 'ci-bot'
      - 'github-actions'
      - 'gitlab-runner'
    source_ip|cidr:
      - '10.0.10.0/24'   # CI runner subnet
  condition: selection_repo and selection_push and not filter_ci
fields:
  - repository
  - tag
  - actor
  - source_ip
  - timestamp
falsepositives:
  - Emergency manual pushes by platform team
level: critical
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.persistence
  - attack.t1525
```

### Layer Injection: Manifest Modification Outside CI

**Lab:** 3.5 Layer Injection | **Log Source:** Container registry audit logs

Detects container image manifest modifications that did not originate from the CI pipeline, indicating direct layer injection via the registry API.

```yaml
title: Layer Injection - Manifest Modified Outside CI Pipeline
id: c1d2e3f4-3501-4c5d-a67e-89b0c1d2e3f4
status: experimental
description: >
  A container image manifest was updated via the registry API from
  a source that is not the CI pipeline. Layer injection requires
  only registry write access and produces no build-time logs.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: application
  product: container_registry
detection:
  selection:
    event_type: 'manifest.put'
  filter_ci:
    actor|contains:
      - 'ci-bot'
      - 'github-actions'
      - 'gitlab-runner'
  condition: selection and not filter_ci
fields:
  - repository
  - tag
  - digest
  - actor
  - source_ip
  - timestamp
falsepositives:
  - Manual image pushes by platform team (should be rare)
level: high
tags:
  - attack.persistence
  - attack.t1525
  - attack.execution
  - attack.t1059
```

### Multi-Stage Leaks: Secrets in Image Layers

**Lab:** 3.6 Multi-Stage Leaks | **Log Source:** Image scanning, CI build logs

Detects secret values (API keys, private keys, passwords) embedded in container image layers or environment variables.

```yaml
title: Multi-Stage Leak - Secret Pattern in Container Image
id: d2e3f4a5-3601-4d6e-b78f-90c1d2e3f4a5
status: experimental
description: >
  Container image scanning found credential patterns in image layers,
  ENV variables, or build history. Secrets passed via ARG or ENV
  persist in layer metadata and are extractable by anyone with
  pull access.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: application
  product: container_scanner
detection:
  selection:
    event_type: 'image.scan.complete'
  secret_found:
    finding_type: 'secret'
    finding_pattern|contains:
      - 'private_key'
      - 'api_key'
      - 'password'
      - 'token'
      - 'AWS_SECRET'
      - 'PRIVATE KEY'
  condition: selection and secret_found
fields:
  - image_name
  - image_tag
  - finding_pattern
  - layer_digest
  - severity
falsepositives:
  - Test images with dummy credentials (should still be flagged)
level: critical
tags:
  - attack.credential_access
  - attack.t1552.001
  - attack.persistence
  - attack.t1525
```

</details>

<details open>
<summary>Tier 4: SBOM & Signing (SBOM and signing tool patterns)</summary>

### SBOM Coverage Gaps: Drift Between SBOM and Runtime

**Lab:** 4.1 SBOM Contents, 4.2 SBOM Gaps | **Log Source:** CI pipeline logs, vulnerability scanner

Detects significant discrepancies between the SBOM component count and the actual package count inside the deployed container.

```yaml
title: SBOM Gap - Component Count Mismatch
id: e3f4a5b6-4101-4e7f-c89a-01d2e3f4a5b6
status: experimental
description: >
  The SBOM lists significantly fewer components than are actually
  installed in the container. This gap means vulnerabilities exist
  in deployed software that your SBOM-based monitoring cannot see.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: application
  product: sbom_validator
detection:
  selection:
    event_type: 'sbom.validation'
  gap_detected:
    actual_package_count|gt: sbom_component_count
    delta|gt: 5
  condition: selection and gap_detected
fields:
  - image_name
  - sbom_component_count
  - actual_package_count
  - delta
  - missing_packages
falsepositives:
  - OS-level packages intentionally excluded from application SBOM
level: medium
tags:
  - attack.defense_evasion
  - attack.t1036
```

### Attestation Forgery: OIDC Issuer Mismatch

**Lab:** 4.6 Attestation Forgery | **Log Source:** Cosign verification logs, admission controller logs

Detects attestations where the OIDC issuer does not match the expected CI provider, indicating the attestation was created outside the trusted build pipeline.

```yaml
title: Attestation Forgery - OIDC Issuer Mismatch
id: a5b6c7d8-4601-4a9b-e01c-23f4a5b6c7d8
status: experimental
description: >
  An attestation's OIDC certificate issuer does not match the expected
  CI provider (token.actions.githubusercontent.com). This indicates
  the attestation was forged from a developer workstation or
  unauthorized CI system.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: application
  product: cosign_verifier
detection:
  selection:
    event_type: 'attestation.verify'
  issuer_mismatch:
    oidc_issuer|not_equals: 'https://token.actions.githubusercontent.com'
  condition: selection and issuer_mismatch
fields:
  - image_reference
  - oidc_issuer
  - subject
  - builder_id
  - timestamp
falsepositives:
  - Images built by non-GitHub CI systems with different OIDC issuers
level: high
tags:
  - attack.defense_evasion
  - attack.t1553
  - attack.supply_chain_compromise
  - attack.t1195.002
```

### SBOM Tampering: Version Mismatch Between SBOM and Scanner

**Lab:** 4.7 SBOM Tampering | **Log Source:** Vulnerability scanner, SBOM validation pipeline

Detects cases where the SBOM claims a different version of a package than what the vulnerability scanner finds in the actual container.

```yaml
title: SBOM Tampering - Version Discrepancy Detected
id: b6c7d8e9-4701-4b0c-f12d-34a5b6c7d8e9
status: experimental
description: >
  A vulnerability scanner found a different version of a package
  than what the SBOM declares. This indicates the SBOM was tampered
  with to hide vulnerable components, or the SBOM is stale.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: application
  product: sbom_validator
detection:
  selection:
    event_type: 'sbom.cross_validation'
  version_mismatch:
    sbom_version|not_equals: scanner_version
  condition: selection and version_mismatch
fields:
  - image_name
  - package_name
  - sbom_version
  - scanner_version
  - cve_id
falsepositives:
  - SBOM generated before final build step that modified dependencies
level: high
tags:
  - attack.defense_evasion
  - attack.t1036
  - attack.supply_chain_compromise
  - attack.t1195.002
```

</details>

<details open>
<summary>Tier 6: Case Studies & Frontier Attacks (specialized patterns)</summary>

### Firmware Supply Chain: Unauthorized Firmware Update

**Lab:** 6.3 Firmware Supply Chain | **Log Source:** BMC/IPMI logs, fleet management

Detects firmware update events outside approved maintenance windows or from unapproved sources.

```yaml
title: Firmware Attack - Update Outside Maintenance Window
id: d4e5f6a7-6301-4d8e-b90f-12c3d4e5f6a7
status: experimental
description: >
  A firmware update was applied outside the designated maintenance
  window or from an unapproved source IP. Firmware attacks operate
  below OS-level monitoring and survive OS reinstallation.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: application
  product: bmc
detection:
  selection:
    event_type: 'firmware.update'
  filter_maintenance:
    timestamp|timeframe:
      start: '02:00'
      end: '06:00'
      weekday: 'sunday'
  filter_source:
    source_ip|cidr:
      - '10.0.20.0/24'   # fleet management subnet
  condition: selection and (not filter_maintenance or not filter_source)
fields:
  - hostname
  - firmware_version
  - source_ip
  - timestamp
falsepositives:
  - Emergency out-of-band firmware patches
level: critical
tags:
  - attack.persistence
  - attack.t1542
  - attack.defense_evasion
  - attack.t1553
```

### Multi-Vector Attack: Cross-Layer Kill Chain Correlation

**Lab:** 6.4 Multi-Vector Attack | **Log Source:** SIEM correlation

Correlates signals across package, CI, container, and runtime layers to detect chained supply chain attacks where no single indicator is conclusive.

```yaml
title: Multi-Vector Attack - Cross-Layer Correlation
id: e5f6a7b8-6401-4e9f-c01a-23d4e5f6a7b8
status: experimental
description: >
  Multiple supply chain indicators from different layers occurred
  within a 24-hour window targeting the same repository or service.
  Individual signals may be low confidence, but the combination
  indicates a coordinated multi-vector attack.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: correlation
detection:
  package_layer:
    event_type: 'new_dependency'
  ci_layer:
    event_type|contains:
      - 'workflow.modified'
      - 'ci_config.changed'
  container_layer:
    event_type: 'image.digest_changed'
  runtime_layer:
    event_type: 'outbound_connection'
    destination|not_in_approved_list: true
  timeframe: 24h
  condition: (package_layer and ci_layer) or (ci_layer and container_layer) or (package_layer and container_layer and runtime_layer)
fields:
  - repository
  - service
  - event_type
  - timestamp
falsepositives:
  - Normal development activity combining dependency updates with CI changes
level: high
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.execution
  - attack.t1059
```

### xz-utils (CVE-2024-3094): Backdoored liblzma Detection

**Lab:** 6.5 xz-utils | **Log Source:** Host inventory, vulnerability scanner

Detects systems running the backdoored liblzma versions (5.6.0, 5.6.1) linked to sshd.

```yaml
title: xz-utils Backdoor - Vulnerable liblzma Version
id: f6a7b8c9-6501-4f0a-d12b-34e5f6a7b8c9
status: experimental
description: >
  A host has liblzma version 5.6.0 or 5.6.1 installed, which contains
  the CVE-2024-3094 backdoor. If sshd is linked against this library,
  the SSH authentication process is compromised.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: application
  product: vulnerability_scanner
detection:
  selection:
    package_name:
      - 'liblzma5'
      - 'liblzma'
      - 'xz-utils'
      - 'xz-libs'
    package_version|startswith:
      - '5.6.0'
      - '5.6.1'
  condition: selection
fields:
  - hostname
  - package_name
  - package_version
  - installed_date
falsepositives:
  - None. These versions contain a confirmed backdoor.
level: critical
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.persistence
  - attack.t1554
```

### SolarWinds: Build Artifact Anomaly

**Lab:** 6.6 SolarWinds | **Log Source:** Build pipeline

Detects build artifacts with unexpected hash values indicating build-time compromise.

```yaml
title: Build Compromise - Artifact Hash Mismatch
id: b8c9d0e1-6602-4b2c-f34d-56a7b8c9d0e1
status: experimental
description: >
  A build artifact has a different hash than expected from the same
  source commit. This is the generic detection for build-time
  compromise attacks like SUNBURST where malicious code is injected
  during the build process itself.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: application
  product: ci_runner
detection:
  selection:
    event_type: 'artifact.publish'
  hash_mismatch:
    artifact_hash|not_equals: expected_hash
  condition: selection and hash_mismatch
fields:
  - artifact_name
  - artifact_hash
  - expected_hash
  - source_commit
  - build_id
falsepositives:
  - Non-reproducible builds (timestamps, build IDs embedded in artifacts)
level: high
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.defense_evasion
  - attack.t1027
```

### event-stream: Maintainer Takeover and Malicious Update

**Lab:** 6.8 event-stream | **Log Source:** npm registry monitoring

Detects maintainer changes in monitored packages followed by new transitive dependencies being added, the event-stream attack pattern.

```yaml
title: event-stream Style - npm Package Maintainer Change
id: d0e1f2a3-6801-4d4e-b56f-78c9d0e1f2a3
status: experimental
description: >
  A monitored npm package changed maintainers and subsequently added
  new transitive dependencies. The event-stream attack used social
  engineering to gain maintainer access, then injected a malicious
  dependency targeting specific cryptocurrency wallets.
author: WeakLink Labs
date: 2026/04/07
logsource:
  category: application
  product: npm_registry_monitor
detection:
  selection:
    event_type: 'package.maintainer_change'
  new_dependency:
    event_type: 'package.new_dependency'
    timeframe|within: '7d'
  condition: selection and new_dependency
fields:
  - package_name
  - old_maintainer
  - new_maintainer
  - new_dependency_name
  - timestamp
falsepositives:
  - Legitimate maintainer transitions in open source projects
level: high
tags:
  - attack.supply_chain_compromise
  - attack.t1195.002
  - attack.persistence
  - attack.t1098
```

</details>

---

## MITRE ATT&CK Mapping

All techniques referenced by the detection rules in this library:

| Technique | ID | Coverage | Rules |
|-----------|-----|-------|-------|
| Supply Chain Compromise: Software Supply Chain | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Tiers 1, 2, 3, 4, 5, 6 plus cloud reference scenarios | Dependency confusion, PPE, base image poisoning, Helm poisoning, Terraform modules, SUNBURST, marketplace poisoning, IAM chain abuse |
| Supply Chain Compromise: Software Dependencies | [T1195.001](https://attack.mitre.org/techniques/T1195/001/) | 1 | Phantom dependencies |
| Command and Scripting Interpreter: Python | [T1059.006](https://attack.mitre.org/techniques/T1059/006/) | 1, 6 | setup.py execution, ML model deserialization |
| Command and Scripting Interpreter: Unix Shell | [T1059.004](https://attack.mitre.org/techniques/T1059/004/) | 2, 6 | Indirect PPE, Codecov script tampering |
| Command and Scripting Interpreter | [T1059](https://attack.mitre.org/techniques/T1059/) | Tiers 2, 3, 5, 6 plus cloud reference scenarios | Direct PPE, Actions injection, layer injection, Terraform, Log4Shell, serverless |
| Automated Exfiltration | [T1020](https://attack.mitre.org/techniques/T1020/) | 1, 2, 5 | Dependency confusion, secret exfiltration, DNS tunneling, Terraform |
| User Execution: Malicious File | [T1204.002](https://attack.mitre.org/techniques/T1204/002/) | 1 | Typosquatting |
| Masquerading | [T1036](https://attack.mitre.org/techniques/T1036/) | 1, 3, 4 | Typosquatting, image internals, SBOM gap |
| Masquerading: Match Legitimate Name | [T1036.005](https://attack.mitre.org/techniques/T1036/005/) | 1, 3 | Manifest confusion, registry confusion |
| Trusted Relationship | [T1199](https://attack.mitre.org/techniques/T1199/) | 1 | Dependency resolution (multi-registry trust) |
| Subvert Trust Controls | [T1553](https://attack.mitre.org/techniques/T1553/) | 1, 4, 6 | Lockfile injection, signature bypass, attestation forgery, firmware |
| Phishing via Code Review | [T1566.001](https://attack.mitre.org/techniques/T1566/001/) | 1 | Lockfile injection |
| Hijack Execution Flow | [T1574](https://attack.mitre.org/techniques/T1574/) | 1, 2 | Manifest confusion, phantom dependencies, cache poisoning, workflow run |
| Implant Internal Image | [T1525](https://attack.mitre.org/techniques/T1525/) | Tiers 3, 6 plus cloud reference scenarios | Image internals, tag mutability, base image poisoning, layer injection, multi-stage leaks, marketplace poisoning |
| Deploy Container | [T1610](https://attack.mitre.org/techniques/T1610/) | 3 | Tag mutability (K8s auto-pull) |
| Unsecured Credentials: Credentials in Files | [T1552.001](https://attack.mitre.org/techniques/T1552/001/) | Tiers 2, 3 plus cloud reference scenarios | Secret exfiltration, multi-stage leaks, cloud CI/CD |
| Scheduled Task/Job | [T1053](https://attack.mitre.org/techniques/T1053/) | 2 | Self-hosted runner persistence |
| Exploit Public-Facing Application | [T1190](https://attack.mitre.org/techniques/T1190/) | 2, 6 | Actions injection, Log4Shell, Equifax |
| Valid Accounts: Cloud Accounts | [T1078.004](https://attack.mitre.org/techniques/T1078/004/) | Cloud reference scenarios | Marketplace poisoning, IAM chain abuse |
| Use Alternate Authentication Material | [T1550.001](https://attack.mitre.org/techniques/T1550/001/) | Cloud reference scenarios | IAM chain abuse (STS token chaining) |
| Acquire Infrastructure: Serverless | [T1583.007](https://attack.mitre.org/techniques/T1583/007/) | Cloud reference scenarios | Serverless C2/exfil |
| Data Manipulation: Stored Data | [T1565.001](https://attack.mitre.org/techniques/T1565/001/) | 6 | Dataset poisoning |
| Execution Guardrails | [T1480](https://attack.mitre.org/techniques/T1480/) | 6 | ML model conditional payload |
| Pre-OS Boot | [T1542](https://attack.mitre.org/techniques/T1542/) | 6 | Firmware persistence |
| Compromise Client Software Binary | [T1554](https://attack.mitre.org/techniques/T1554/) | 6 | xz-utils backdoor |
| Account Manipulation: SSH Authorized Keys | [T1098.004](https://attack.mitre.org/techniques/T1098/004/) | 5 | Ansible Galaxy SSH backdoor |
| Escape to Host | [T1611](https://attack.mitre.org/techniques/T1611/) | 5 | Admission controller bypass |
| Impair Defenses | [T1562](https://attack.mitre.org/techniques/T1562/) | 5, 6 | Admission bypass, dataset poisoning (ML misclassification) |
| DNS Application Layer Protocol | [T1071.004](https://attack.mitre.org/techniques/T1071/004/) | 2, 6 | DNS exfiltration, SUNBURST C2 |
| Account Manipulation | [T1098](https://attack.mitre.org/techniques/T1098/) | 6 | event-stream maintainer takeover |
