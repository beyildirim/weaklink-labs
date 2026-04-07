# CI Security Snippets

A collection of ready-to-use GitHub Actions workflows for supply chain security. Each snippet is a standalone workflow you can copy into your `.github/workflows/` directory. Organized by security domain, with links back to the lab that covers the underlying attack.

---

???+ abstract "Dependency Security"

    Workflows that prevent dependency-level supply chain attacks: registry confusion, typosquatting, lockfile tampering, phantom dependencies, and manifest confusion.

    ### Reject extra-index-url in pip Config

    **Related lab:** <a href="../labs/tier-1/1.1-dependency-resolution/">Lab 1.1</a>

    Prevents pip from searching multiple registries, which is the root cause of dependency confusion attacks. Use this when your project uses private PyPI packages.

    `.github/workflows/pip-config-check.yml`:

    ```yaml
    name: Dependency Resolution Safety Check

    on:
      pull_request:
        paths:
          - "requirements*.txt"
          - "setup.py"
          - "setup.cfg"
          - "pyproject.toml"
          - "pip.conf"
          - ".pip/**"

    jobs:
      check-pip-config:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4

          - name: Reject extra-index-url in pip config
            run: |
              echo "--- Scanning for extra-index-url usage ---"
              FOUND=0
              for f in pip.conf .pip/pip.conf setup.cfg pyproject.toml; do
                if [ -f "$f" ]; then
                  if grep -qi "extra-index-url" "$f"; then
                    echo "::error file=$f::BLOCKED: $f contains extra-index-url. Use --index-url instead."
                    FOUND=1
                  fi
                fi
              done
              for f in requirements*.txt; do
                if [ -f "$f" ]; then
                  if grep -qi "\-\-extra-index-url" "$f"; then
                    echo "::error file=$f::BLOCKED: $f contains --extra-index-url inline flag."
                    FOUND=1
                  fi
                fi
              done
              if [ "$FOUND" -eq 1 ]; then
                exit 1
              fi
              echo "PASS: No extra-index-url found."

          - name: Verify lockfile exists
            run: |
              if [ -f "requirements.lock" ] || [ -f "requirements-lock.txt" ] || \
                 [ -f "poetry.lock" ] || [ -f "Pipfile.lock" ] || [ -f "pdm.lock" ]; then
                echo "PASS: Lockfile found."
              else
                echo "::error::No lockfile found. Run 'pip freeze > requirements.lock' and commit it."
                exit 1
              fi

          - name: Check version pins in requirements.txt
            run: |
              UNPINNED=0
              for f in requirements*.txt; do
                if [ -f "$f" ]; then
                  while IFS= read -r line; do
                    [[ "$line" =~ ^[[:space:]]*# ]] && continue
                    [[ "$line" =~ ^[[:space:]]*$ ]] && continue
                    [[ "$line" =~ ^- ]] && continue
                    if ! echo "$line" | grep -q "=="; then
                      echo "::warning file=$f::Unpinned dependency: $line (use == for exact version)"
                      UNPINNED=1
                    fi
                  done < "$f"
                fi
              done
              if [ "$UNPINNED" -eq 1 ]; then
                echo "WARNING: Some dependencies are not pinned to exact versions."
              else
                echo "PASS: All dependencies are pinned."
              fi
    ```

    ---

    ### Dependency Confusion Prevention (Scope Enforcement)

    **Related lab:** <a href="../labs/tier-1/1.2-dependency-confusion/">Lab 1.2</a>

    Detects internal package names resolving from public registries. Use this in any organization that maintains private packages alongside public PyPI dependencies.

    `.github/workflows/dep-confusion-check.yml`:

    ```yaml
    name: Dependency Confusion Prevention

    on:
      pull_request:
        paths:
          - "requirements*.txt"
          - "pyproject.toml"
          - "setup.cfg"

    jobs:
      check-confusion:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4

          - name: Flag internal package names
            env:
              INTERNAL_PREFIXES: "wl-,internal-,company-,myorg-"
            run: |
              FOUND=0
              IFS=',' read -ra PREFIXES <<< "$INTERNAL_PREFIXES"
              for f in requirements*.txt; do
                [ -f "$f" ] || continue
                while IFS= read -r line; do
                  [[ "$line" =~ ^[[:space:]]*# ]] && continue
                  [[ "$line" =~ ^[[:space:]]*$ ]] && continue
                  pkg=$(echo "$line" | sed 's/[>=<!=;\[].*//' | xargs | tr '[:upper:]' '[:lower:]')
                  [ -z "$pkg" ] && continue
                  for prefix in "${PREFIXES[@]}"; do
                    if [[ "$pkg" == ${prefix}* ]]; then
                      echo "::error file=$f::Internal package '$pkg' must come from --index-url only (not --extra-index-url)"
                      FOUND=1
                    fi
                  done
                done < "$f"
              done
              if [ "$FOUND" -eq 1 ]; then
                echo "Verify pip.conf uses --index-url (single registry) for internal packages."
                exit 1
              fi
              echo "PASS: No dependency confusion risk detected."
    ```

    ---

    ### Typosquatting Detection (Levenshtein Distance)

    **Related lab:** <a href="../labs/tier-1/1.3-typosquatting/">Lab 1.3</a>

    Compares every dependency name against a list of popular packages. Flags any package within 1 edit distance. Use this on every repository that installs packages from public PyPI.

    `.github/workflows/typosquatting-check.yml`:

    ```yaml
    name: Typosquatting Prevention

    on:
      pull_request:
        paths:
          - "requirements*.txt"
          - "setup.py"
          - "setup.cfg"
          - "pyproject.toml"

    jobs:
      check-typosquatting:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4

          - name: Set up Python
            uses: actions/setup-python@v5
            with:
              python-version: "3.12"

          - name: Check for typosquatted packages
            run: |
              python3 << 'PYEOF'
              import sys, re
              from pathlib import Path

              def levenshtein_distance(s1, s2):
                  if len(s1) < len(s2):
                      return levenshtein_distance(s2, s1)
                  if len(s2) == 0:
                      return len(s1)
                  prev_row = range(len(s2) + 1)
                  for i, c1 in enumerate(s1):
                      curr_row = [i + 1]
                      for j, c2 in enumerate(s2):
                          curr_row.append(min(
                              prev_row[j + 1] + 1,
                              curr_row[j] + 1,
                              prev_row[j] + (c1 != c2),
                          ))
                      prev_row = curr_row
                  return prev_row[-1]

              KNOWN_PACKAGES = [
                  "requests", "numpy", "pandas", "flask", "django", "boto3",
                  "urllib3", "setuptools", "pip", "wheel", "cryptography",
                  "pyyaml", "pyjwt", "pillow", "scipy", "matplotlib",
                  "beautifulsoup4", "sqlalchemy", "celery", "redis",
                  "psycopg2", "pymongo", "colorama", "paramiko", "jinja2",
                  "click", "pytest", "coverage", "black", "flake8", "mypy",
                  "httpx", "aiohttp", "fastapi", "uvicorn", "gunicorn",
                  "pydantic", "python-dateutil", "python-dotenv", "docker",
                  "kubernetes", "protobuf", "grpcio", "tensorflow", "torch",
                  "transformers", "scrapy", "selenium", "ansible", "fabric",
              ]

              issues_found = 0
              for req_file in Path(".").glob("requirements*.txt"):
                  with open(req_file) as f:
                      for line_num, line in enumerate(f, 1):
                          line = line.strip()
                          if not line or line.startswith("#") or line.startswith("-"):
                              continue
                          pkg = re.split(r"[>=<!;\[]", line)[0].strip()
                          if not pkg:
                              continue
                          pkg_norm = pkg.lower().replace("_", "-")
                          if pkg_norm in KNOWN_PACKAGES:
                              continue
                          for known in KNOWN_PACKAGES:
                              dist = levenshtein_distance(pkg_norm, known)
                              if dist == 1:
                                  print(
                                      f"::error file={req_file},line={line_num}::"
                                      f"TYPOSQUATTING RISK: '{pkg}' is 1 edit from '{known}'."
                                  )
                                  issues_found += 1
                              elif dist == 2 and len(pkg_norm) > 5:
                                  print(
                                      f"::warning file={req_file},line={line_num}::"
                                      f"Possible typosquat: '{pkg}' is 2 edits from '{known}'."
                                  )

              if issues_found > 0:
                  print(f"\nFound {issues_found} potential typosquatting issue(s).")
                  sys.exit(1)
              else:
                  print("PASS: No typosquatting risks detected.")
              PYEOF

          - name: Enforce package allowlist
            run: |
              ALLOWLIST_FILE="allowed-packages.txt"
              if [ ! -f "$ALLOWLIST_FILE" ]; then
                echo "::warning::No allowed-packages.txt found. Create one to enforce an allowlist."
                exit 0
              fi
              BLOCKED=0
              for f in requirements*.txt; do
                if [ -f "$f" ]; then
                  while IFS= read -r line; do
                    [[ "$line" =~ ^[[:space:]]*# ]] && continue
                    [[ "$line" =~ ^[[:space:]]*$ ]] && continue
                    [[ "$line" =~ ^- ]] && continue
                    pkg=$(echo "$line" | sed 's/[>=<!=;\[].*//' | xargs | tr '[:upper:]' '[:lower:]' | tr '_' '-')
                    [ -z "$pkg" ] && continue
                    if ! grep -qi "^${pkg}$" "$ALLOWLIST_FILE"; then
                      echo "::error file=$f::BLOCKED: Package '${pkg}' is not in the allowlist."
                      BLOCKED=1
                    fi
                  done < "$f"
                fi
              done
              if [ "$BLOCKED" -eq 1 ]; then
                exit 1
              fi
              echo "PASS: All packages are on the allowlist."
    ```

    ---

    ### Lockfile Integrity Verification

    **Related lab:** <a href="../labs/tier-1/1.4-lockfile-injection/">Lab 1.4</a>

    Regenerates the lockfile from the manifest and diffs against the committed version. Catches tampered hashes. Use this on any project using pip-compile with `--generate-hashes`.

    `.github/workflows/lockfile-verify.yml`:

    ```yaml
    name: Verify Lockfile Integrity

    on:
      pull_request:
        paths:
          - "requirements.txt"
          - "requirements.in"

    jobs:
      verify-python-lockfile:
        runs-on: ubuntu-latest
        if: hashFiles('requirements.in') != ''
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-python@v5
            with:
              python-version: "3.11"

          - name: Install pip-tools
            run: pip install pip-tools

          - name: Regenerate lockfile from source
            run: |
              pip-compile --generate-hashes \
                requirements.in \
                --output-file /tmp/regenerated-requirements.txt

          - name: Compare against committed lockfile
            run: |
              grep -v '^#' requirements.txt > /tmp/committed.txt
              grep -v '^#' /tmp/regenerated-requirements.txt > /tmp/fresh.txt
              if ! diff /tmp/committed.txt /tmp/fresh.txt; then
                echo "::error::Lockfile mismatch! Regenerate with: pip-compile --generate-hashes requirements.in"
                exit 1
              fi
              echo "Lockfile integrity verified."
    ```

    ---

    ### Manifest Confusion Detection (npm)

    **Related lab:** <a href="../labs/tier-1/1.5-manifest-confusion/">Lab 1.5</a>

    Compares npm registry metadata against actual tarball contents to detect hidden install scripts or undeclared dependencies. Use this on Node.js projects to catch packages where the registry API lies about what is inside.

    `.github/workflows/manifest-verify.yml`:

    ```yaml
    name: Detect Manifest Confusion

    on:
      pull_request:
        paths:
          - "package.json"
          - "package-lock.json"

    jobs:
      check-manifests:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-node@v4
            with:
              node-version: "20"

          - name: Compare registry metadata vs tarball contents
            run: |
              set -euo pipefail
              FAILED=0
              DEPS=$(node -e "
                const pkg = require('./package.json');
                const deps = {...(pkg.dependencies || {}), ...(pkg.devDependencies || {})};
                console.log(Object.keys(deps).join('\n'));
              ")
              mkdir -p /tmp/manifest-check
              cd /tmp/manifest-check
              for dep in $DEPS; do
                echo "Checking $dep..."
                REGISTRY_DEPS=$(npm view "$dep" dependencies --json 2>/dev/null || echo "{}")
                REGISTRY_SCRIPTS=$(npm view "$dep" scripts --json 2>/dev/null || echo "{}")
                npm pack "$dep" --quiet 2>/dev/null
                TARBALL=$(ls -t *.tgz | head -1)
                tar xzf "$TARBALL"
                TARBALL_DEPS=$(node -e "console.log(JSON.stringify(require('./package/package.json').dependencies || {}))")
                TARBALL_SCRIPTS=$(node -e "console.log(JSON.stringify(require('./package/package.json').scripts || {}))")
                if [ "$REGISTRY_DEPS" != "$TARBALL_DEPS" ]; then
                  echo "::error::MANIFEST CONFUSION in $dep: registry dependencies differ from tarball"
                  FAILED=1
                fi
                if echo "$TARBALL_SCRIPTS" | grep -q "postinstall\|preinstall\|install" && \
                   ! echo "$REGISTRY_SCRIPTS" | grep -q "postinstall\|preinstall\|install"; then
                  echo "::error::HIDDEN INSTALL SCRIPT in $dep: tarball has install hooks not shown in registry"
                  FAILED=1
                fi
                rm -rf package "$TARBALL"
              done
              if [ "$FAILED" -eq 1 ]; then
                exit 1
              fi
              echo "All package manifests verified."

          - name: Enforce npm ci over npm install
            run: npm ci
    ```

    ---

    ### Phantom Dependency Detection (depcheck)

    **Related lab:** <a href="../labs/tier-1/1.6-phantom-dependencies/">Lab 1.6</a>

    Finds `require()`/`import` statements for packages not declared in `package.json`. Also flags suspiciously high version numbers in the lockfile. Use this on Node.js projects to eliminate undeclared dependencies that attackers can hijack.

    `.github/workflows/phantom-deps.yml`:

    ```yaml
    name: Detect Phantom Dependencies

    on:
      pull_request:
        paths:
          - "**.js"
          - "**.ts"
          - "package.json"
          - "package-lock.json"
      push:
        branches: [main]

    jobs:
      depcheck:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-node@v4
            with:
              node-version: "20"

          - name: Install dependencies with npm ci
            run: npm ci

          - name: Install depcheck
            run: npm install -g depcheck

          - name: Run depcheck for phantom dependencies
            run: |
              set -euo pipefail
              OUTPUT=$(depcheck . --json 2>/dev/null || true)
              echo "$OUTPUT" | node -e "
                const data = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'));
                const missing = Object.keys(data.missing || {});
                if (missing.length > 0) {
                  console.log('PHANTOM DEPENDENCIES FOUND:');
                  missing.forEach(dep => {
                    const files = data.missing[dep];
                    console.log('  ' + dep + ' (used in: ' + files.join(', ') + ')');
                  });
                  process.exit(1);
                } else {
                  console.log('No phantom dependencies detected.');
                }
              "

          - name: Check for high-version anomalies
            run: |
              node -e "
                const lockfile = require('./package-lock.json');
                const packages = lockfile.packages || {};
                let found = false;
                for (const [path, info] of Object.entries(packages)) {
                  if (!path || !info.version) continue;
                  const major = parseInt(info.version.split('.')[0]);
                  if (major > 50) {
                    console.log('WARNING: ' + path + ' has version ' + info.version + ' (suspiciously high)');
                    found = true;
                  }
                }
                if (found) process.exit(1);
                console.log('No version anomalies detected.');
              "
    ```

    ---

    ### Dependency Hash Verification (pip)

    **Related lab:** <a href="../labs/tier-0/0.2-package-managers/">Lab 0.2</a>

    Ensures `requirements.txt` contains `--hash=sha256:` entries and installs with `--require-hashes`. Use this as a baseline check on every Python project. If hashes mismatch, the package was tampered with.

    `.github/workflows/dependency-hash-check.yml`:

    ```yaml
    name: Dependency Hash Verification

    on:
      pull_request:
        paths:
          - "requirements*.txt"
          - "setup.py"
          - "pyproject.toml"
      push:
        branches: [main]

    permissions:
      contents: read

    jobs:
      verify-hashes:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4

          - uses: actions/setup-python@v5
            with:
              python-version: "3.11"

          - name: Verify requirements.txt has hashes
            run: |
              if [ -f requirements.txt ]; then
                if ! grep -q '\-\-hash=sha256:' requirements.txt; then
                  echo "::error::requirements.txt must use --hash=sha256: for all packages."
                  echo "Generate hashes with: pip-compile --generate-hashes requirements.in"
                  exit 1
                fi
              fi

          - name: Install with --require-hashes
            run: |
              pip install --require-hashes -r requirements.txt
            env:
              PIP_NO_CACHE_DIR: "1"
    ```

---

???+ abstract "Build Pipeline Hardening"

    Workflows that prevent CI/CD pipeline exploitation: poisoned pipeline execution, secret exfiltration, expression injection, cache poisoning, runner persistence, and cross-workflow attacks.

    ### PPE Prevention (Workflow File Change Detection)

    **Related lab:** <a href="../labs/tier-2/2.2-direct-ppe/">Lab 2.2</a>

    Flags any PR that modifies CI config files and requires CODEOWNERS approval. Use this on every repository to prevent PR authors from injecting malicious build steps.

    `.github/workflows/ppe-prevention.yml`:

    ```yaml
    name: PPE Prevention Check

    on:
      pull_request:
        paths:
          - ".github/workflows/**"

    jobs:
      check-workflow-changes:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
            with:
              fetch-depth: 0

          - name: Flag workflow file changes
            run: |
              echo "--- CI config files modified in this PR ---"
              CHANGED=$(git diff --name-only origin/main...HEAD -- \
                '.github/workflows/' '.gitea/workflows/' \
                '.gitlab-ci.yml' 'Jenkinsfile')
              if [ -n "$CHANGED" ]; then
                echo "::warning::CI pipeline configs modified in this PR:"
                echo "$CHANGED"
                echo ""
                echo "These changes require CODEOWNERS approval."
                echo "Reviewer: verify no secret exfiltration, no curl/wget"
                echo "to external hosts, no env/printenv commands."
              fi
    ```

    ---

    ### Indirect PPE Scanner (Build Script Integrity)

    **Related lab:** <a href="../labs/tier-2/2.3-indirect-ppe/">Lab 2.3</a>

    Scans Makefiles, shell scripts, and Dockerfiles for suspicious commands added in a PR. Catches indirect PPE where the CI config is untouched but the files it executes are poisoned.

    `.github/workflows/indirect-ppe-check.yml`:

    ```yaml
    name: Indirect PPE Prevention

    on:
      pull_request:
        paths:
          - "Makefile"
          - "scripts/**"
          - "Dockerfile*"
          - "*.sh"

    jobs:
      check-referenced-files:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
            with:
              fetch-depth: 0

          - name: Scan for suspicious commands in CI-referenced files
            run: |
              echo "--- Scanning files referenced by CI for suspicious commands ---"
              SUSPICIOUS=0

              for f in Makefile scripts/*.sh Dockerfile*; do
                [ -f "$f" ] || continue

                DIFF=$(git diff origin/main...HEAD -- "$f" || true)
                if echo "$DIFF" | grep -qE '^\+.*(curl|wget|nc |ncat|python -c|base64|/tmp/|env\b)'; then
                  echo "::warning file=$f::Suspicious command added to CI-referenced file"
                  echo "$DIFF" | grep -E '^\+.*(curl|wget|nc |ncat|python -c|base64|/tmp/|env\b)'
                  SUSPICIOUS=$((SUSPICIOUS + 1))
                fi
              done

              if [ "$SUSPICIOUS" -gt 0 ]; then
                echo "::error::$SUSPICIOUS CI-referenced file(s) have suspicious changes."
                exit 1
              fi
              echo "PASS: No suspicious changes in CI-referenced files."
    ```

    ---

    ### Secret Leak Prevention (Artifact Scanner)

    **Related lab:** <a href="../labs/tier-2/2.4-secret-exfiltration/">Lab 2.4</a>

    Scans build artifacts for leaked secrets after every workflow completes. Catches credentials written to logs, text files, or build outputs. Use this as a safety net across all pipelines.

    `.github/workflows/secret-leak-scan.yml`:

    ```yaml
    name: Secret Leak Prevention

    on:
      workflow_run:
        workflows: ["*"]
        types: [completed]

    jobs:
      scan-artifacts:
        runs-on: ubuntu-latest
        steps:
          - name: Download artifacts from triggering workflow
            uses: actions/download-artifact@v4
            with:
              run-id: ${{ github.event.workflow_run.id }}
              path: /tmp/artifacts/

          - name: Scan for secret patterns
            run: |
              echo "--- Scanning build artifacts for leaked secrets ---"
              LEAKED=0
              find /tmp/artifacts/ -type f | while read f; do
                if grep -lqE '(ghp_|AKIA|sk-|password=|token=|secret=)' "$f" 2>/dev/null; then
                  echo "::error::Secret pattern found in artifact: $f"
                  LEAKED=1
                fi
              done
              if [ "$LEAKED" -eq 1 ]; then
                echo "CRITICAL: Secrets detected in build artifacts. Rotate immediately."
                exit 1
              fi
              echo "PASS: No secrets found in artifacts."
    ```

    ---

    ### Self-Hosted Runner Integrity Check

    **Related lab:** <a href="../labs/tier-2/2.5-self-hosted-runners/">Lab 2.5</a>

    Verifies that no persistence mechanisms (cron jobs, shell profile modifications, hidden scripts) were planted on the runner after each workflow completes. Use this on every self-hosted runner.

    `.github/workflows/runner-integrity.yml`:

    ```yaml
    name: Runner Integrity Check

    on:
      workflow_run:
        workflows: ["*"]
        types: [completed]

    jobs:
      verify-runner-state:
        runs-on: self-hosted
        steps:
          - name: Check for persistence mechanisms
            run: |
              echo "--- Checking for unexpected files ---"
              SUSPICIOUS=$(find /runner/_work/_tool -name "*.sh" \
                -newer /runner/.last-verified 2>/dev/null)
              if [ -n "$SUSPICIOUS" ]; then
                echo "::error::New scripts found in tool cache:"
                echo "$SUSPICIOUS"
                exit 1
              fi

              echo "--- Checking crontab ---"
              if crontab -l 2>/dev/null | grep -v '^#' | grep -q .; then
                echo "::error::Unexpected cron jobs found"
                exit 1
              fi

              echo "--- Checking shell profiles ---"
              for f in ~/.bash_profile ~/.bashrc ~/.profile; do
                if [ -f "$f" ]; then
                  HASH=$(sha256sum "$f" | cut -d' ' -f1)
                  EXPECTED=$(cat "/runner/.baseline/$(basename $f).hash" 2>/dev/null)
                  if [ "$HASH" != "$EXPECTED" ]; then
                    echo "::error::Shell profile $f has been modified"
                    exit 1
                  fi
                fi
              done

              touch /runner/.last-verified
              echo "Runner state verified clean."
    ```

    ---

    ### Actions Expression Injection Scanner

    **Related lab:** <a href="../labs/tier-2/2.6-actions-injection/">Lab 2.6</a>

    Detects `${{ github.event.* }}` interpolated directly in `run:` blocks, which enables shell command injection via issue titles, PR bodies, or branch names. Use this on every repository that uses GitHub Actions.

    `.github/workflows/injection-scanner.yml`:

    ```yaml
    name: Actions Injection Scanner

    on:
      pull_request:
        paths:
          - ".github/workflows/**"

    jobs:
      scan-for-injection:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4

          - name: Check for direct expression interpolation
            run: |
              echo "Scanning workflows for expression injection..."
              VULNERABLE=0

              for wf in .github/workflows/*.yml; do
                if grep -Pzo '(?s)run:.*?\$\{\{.*?github\.event\.(issue|pull_request|comment|discussion|head_ref|commits)' "$wf" 2>/dev/null; then
                  echo "::error file=$wf::Direct interpolation of user-controlled event data in run: block"
                  VULNERABLE=1
                fi
              done

              if [ "$VULNERABLE" -eq 1 ]; then
                echo "Fix: Use env: to assign expressions to environment variables"
                exit 1
              fi

              echo "No injection vulnerabilities found."

          - name: Run Zizmor (optional)
            if: always()
            run: |
              pip install zizmor 2>/dev/null && \
              zizmor .github/workflows/ || true
    ```

    ---

    ### Build Cache Integrity Verification

    **Related lab:** <a href="../labs/tier-2/2.7-build-cache-poisoning/">Lab 2.7</a>

    Verifies that cached packages match lockfile hashes after cache restore. Prevents PR-created caches from poisoning default branch builds. Use this on pipelines that use `actions/cache`.

    `.github/workflows/cache-integrity.yml`:

    ```yaml
    name: Cache Integrity Check

    on:
      push:
        branches: [main]
        paths:
          - "requirements.txt"
          - "requirements-lock.txt"
          - "package-lock.json"

    jobs:
      verify-cache:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4

          - name: Restore cache
            uses: actions/cache@v4
            id: cache
            with:
              path: ~/.cache/pip
              key: pip-${{ runner.os }}-${{ hashFiles('requirements-lock.txt') }}

          - name: Verify cached package integrity
            if: steps.cache.outputs.cache-hit == 'true'
            run: |
              echo "Cache was restored. Verifying integrity..."
              pip install --require-hashes \
                --no-deps \
                --no-index \
                --find-links ~/.cache/pip/wheels/ \
                -r requirements-lock.txt 2>&1 | tee /tmp/verify.log

              if grep -q "hash mismatch\|HASH MISMATCH" /tmp/verify.log; then
                echo "::error::Cache integrity check FAILED"
                rm -rf ~/.cache/pip/wheels/*
                exit 1
              fi
              echo "Cache integrity verified."

          - name: Fresh install on cache miss
            if: steps.cache.outputs.cache-hit != 'true'
            run: |
              pip install --require-hashes -r requirements-lock.txt
    ```

    ---

    ### Cross-Workflow Artifact Safety

    **Related lab:** <a href="../labs/tier-2/2.8-workflow-run-attacks/">Lab 2.8</a>

    Checks that no `workflow_run` workflow downloads and then executes artifact contents. Prevents privilege escalation from PR builds into contexts with write permissions and secrets.

    `.github/workflows/artifact-safety.yml`:

    ```yaml
    name: Artifact Safety Check

    on:
      pull_request:
        paths:
          - ".github/workflows/**"

    jobs:
      audit-workflows:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4

          - name: Check artifacts for executable content
            uses: actions/github-script@v7
            with:
              script: |
                const fs = require('fs');
                const path = require('path');
                const dir = '.github/workflows';
                const files = fs.readdirSync(dir).filter(f => f.endsWith('.yml'));

                for (const file of files) {
                  const content = fs.readFileSync(path.join(dir, file), 'utf8');
                  if (content.includes('workflow_run') && content.includes('download-artifact')) {
                    if (/download-artifact[\s\S]{0,500}run:[\s\S]{0,200}(bash|sh|python|node)/.test(content)) {
                      core.error(`${file}: workflow_run workflow downloads and executes artifacts. This is a privilege escalation risk.`);
                    }
                  }
                }

          - name: Verify no workflow_run executes artifacts
            run: |
              for wf in .github/workflows/*.yml; do
                if grep -q "workflow_run" "$wf"; then
                  if grep -q "download-artifact" "$wf" && \
                     grep -Pzo '(?s)download-artifact.*?run:.*?(bash|sh|python|node)' "$wf" 2>/dev/null; then
                    echo "::error file=$wf::workflow_run workflow downloads and executes artifacts"
                  fi
                fi
              done
    ```

    ---

    ### Cloud CI/CD Build Role Auditor

    **Related lab:** <a href="../labs/tier-9/9.3-cloud-cicd-attacks/">Lab 9.3</a>

    Validates that CI/CD build roles (CodeBuild, Cloud Build) follow least privilege and cannot access production secrets or assume admin roles. Use this in AWS/GCP environments where build pipelines have IAM role access.

    `.github/workflows/cloud-cicd-audit.yml`:

    ```yaml
    name: Cloud CI/CD Role Audit

    on:
      pull_request:
        paths:
          - "buildspec.yml"
          - "cloudbuild.yaml"
          - "**/*.tf"
          - "iam/**"

    jobs:
      audit-build-role:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4

          - name: Check buildspec for privilege escalation
            run: |
              FOUND=0
              for f in buildspec.yml cloudbuild.yaml; do
                [ -f "$f" ] || continue
                if grep -qE '(sts:AssumeRole|iam:Create|ssm:GetParameter.*/prod/)' "$f"; then
                  echo "::error file=$f::Build config accesses production IAM/SSM resources"
                  FOUND=1
                fi
                if grep -qE '(aws iam|gcloud iam)' "$f"; then
                  echo "::error file=$f::Build config modifies IAM. This should not happen in CI."
                  FOUND=1
                fi
              done
              [ "$FOUND" -eq 0 ] || exit 1
              echo "PASS: No privilege escalation in build configs."

          - name: Check Terraform for overprivileged build roles
            run: |
              for f in $(find . -name "*.tf" -not -path "*/.terraform/*"); do
                if grep -A5 'codebuild\|cloudbuild' "$f" | grep -qE 'AdministratorAccess|PowerUserAccess|\*:\*'; then
                  echo "::error file=$f::Build role has overprivileged IAM policy"
                  exit 1
                fi
              done
              echo "PASS: Build roles follow least privilege."
    ```

---

???+ abstract "Container Security"

    Workflows for container image integrity: layer auditing, tag pinning, base image verification, registry qualification, secret leak scanning, and image signing.

    ### Container Image Layer Audit

    **Related lab:** <a href="../labs/tier-3/3.1-image-internals/">Lab 3.1</a>

    Detects add-then-delete patterns in image history (indicating secrets or binaries hidden in intermediate layers) and verifies layer count against the Dockerfile. Use this when building container images in CI.

    `.github/workflows/image-layer-audit.yml`:

    ```yaml
    name: Container Image Layer Audit

    on:
      push:
        paths:
          - "Dockerfile*"

    jobs:
      audit-layers:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4

          - name: Install crane
            run: |
              curl -sL https://github.com/google/go-containerregistry/releases/latest/download/go-containerregistry_Linux_x86_64.tar.gz \
                | tar xz crane
              sudo mv crane /usr/local/bin/

          - name: Build image
            run: docker build -t audit-target:latest .

          - name: Check for add-then-delete pattern
            run: |
              HISTORY=$(docker history --no-trunc --format '{{.CreatedBy}}' audit-target:latest)
              if echo "$HISTORY" | grep -qE '(rm -rf|rm -f|rm /)' ; then
                echo "::warning::Image history contains file deletion after addition."
                echo "Use multi-stage builds to avoid this pattern."
              fi

          - name: Verify layer count
            run: |
              EXPECTED_LAYERS=$(grep -cE '^(RUN|COPY|ADD) ' Dockerfile || echo 0)
              ACTUAL_LAYERS=$(docker inspect --format '{{len .RootFS.Layers}}' audit-target:latest)
              echo "Dockerfile instructions: $EXPECTED_LAYERS"
              echo "Actual image layers: $ACTUAL_LAYERS"
              if [ "$ACTUAL_LAYERS" -gt $((EXPECTED_LAYERS + 15)) ]; then
                echo "::error::Image has significantly more layers than expected."
                exit 1
              fi

          - name: Scan all layers with Trivy
            uses: aquasecurity/trivy-action@master
            with:
              image-ref: audit-target:latest
              severity: CRITICAL,HIGH
              exit-code: 1
    ```

    ---

    ### Image Digest Enforcement (Reject Tag-Only References)

    **Related lab:** <a href="../labs/tier-3/3.2-tag-mutability/">Lab 3.2</a>

    Scans Kubernetes manifests for image references that use tags without `@sha256:` digest pinning. Prevents silent tag overwrites. Use this on every repository that deploys containers to Kubernetes.

    `.github/workflows/digest-check.yml`:

    ```yaml
    name: Image Digest Enforcement

    on:
      pull_request:
        paths:
          - "k8s/**"
          - "deploy/**"
          - "helm/**"

    jobs:
      check-digests:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4

          - name: Reject tag-only image references
            run: |
              FOUND=0
              for f in $(find k8s/ deploy/ helm/ -name '*.yml' -o -name '*.yaml' 2>/dev/null); do
                while IFS= read -r line; do
                  if echo "$line" | grep -qE 'image:.*:[a-zA-Z0-9._-]+$' && \
                     ! echo "$line" | grep -q '@sha256:'; then
                    echo "::error file=$f::Tag-only image reference found: $line"
                    FOUND=1
                  fi
                done < "$f"
              done
              if [ "$FOUND" -eq 1 ]; then
                exit 1
              fi
              echo "PASS: All image references use digests."
    ```

    ---

    ### Base Image Integrity Check

    **Related lab:** <a href="../labs/tier-3/3.3-base-image-poisoning/">Lab 3.3</a>

    Verifies all `FROM` instructions use digest-pinned references and scans base images for critical vulnerabilities. Runs daily and on Dockerfile changes. Use this to prevent base image supply chain attacks.

    `.github/workflows/base-image-verify.yml`:

    ```yaml
    name: Base Image Integrity Check

    on:
      push:
        paths:
          - "Dockerfile*"
      schedule:
        - cron: "0 6 * * *"

    jobs:
      verify-base:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4

          - name: Install crane
            run: |
              curl -sL https://github.com/google/go-containerregistry/releases/latest/download/go-containerregistry_Linux_x86_64.tar.gz \
                | tar xz crane
              sudo mv crane /usr/local/bin/

          - name: Verify base image digests
            run: |
              UNPINNED=0
              while IFS= read -r line; do
                if echo "$line" | grep -qE '^FROM ' && ! echo "$line" | grep -q '@sha256:'; then
                  IMAGE=$(echo "$line" | awk '{print $2}')
                  echo "::error::Base image not pinned by digest: $IMAGE"
                  UNPINNED=1
                fi
              done < <(grep -h '^FROM ' Dockerfile*)
              if [ "$UNPINNED" -eq 1 ]; then
                exit 1
              fi
              echo "PASS: All base images are pinned by digest."

          - name: Scan base images
            run: |
              for image in $(grep -ohE '@sha256:[a-f0-9]+' Dockerfile* | sort -u); do
                BASE=$(grep -B1 "$image" Dockerfile* | grep 'FROM' | awk '{print $2}')
                echo "Scanning: $BASE"
                docker pull "$BASE" 2>/dev/null
                trivy image --severity CRITICAL "$BASE"
              done
    ```

    ---

    ### Registry Qualification Check

    **Related lab:** <a href="../labs/tier-3/3.4-registry-confusion/">Lab 3.4</a>

    Rejects unqualified image names (e.g., `myapp:latest` instead of `registry.internal.corp/myapp:latest`) in Kubernetes manifests. Prevents Docker from resolving images from public registries when you intend to use a private one.

    `.github/workflows/registry-check.yml`:

    ```yaml
    name: Registry Qualification Check

    on:
      pull_request:
        paths:
          - "k8s/**"
          - "deploy/**"
          - "helm/**"

    jobs:
      check-registry-refs:
        runs-on: ubuntu-latest
        env:
          ALLOWED_REGISTRIES: "registry.internal.corp,gcr.io/distroless,registry.k8s.io"
        steps:
          - uses: actions/checkout@v4

          - name: Reject unqualified image names
            run: |
              FOUND=0
              for f in $(find k8s/ deploy/ helm/ -name '*.yml' -o -name '*.yaml' 2>/dev/null); do
                while IFS= read -r line; do
                  IMAGE=$(echo "$line" | grep -oP 'image:\s*\K\S+')
                  [ -z "$IMAGE" ] && continue
                  if ! echo "$IMAGE" | grep -qE '^[a-z0-9.-]+[.:][a-z0-9]+/'; then
                    echo "::error file=$f::Unqualified image name: $IMAGE"
                    FOUND=1
                  fi
                done < "$f"
              done
              if [ "$FOUND" -eq 1 ]; then
                exit 1
              fi
              echo "PASS: All image references are fully qualified."
    ```

    ---

    ### Layer Injection Guard (Build, Sign, and Baseline)

    **Related lab:** <a href="../labs/tier-3/3.5-layer-injection/">Lab 3.5</a>

    Builds, signs, and records a layer baseline for the image. Use this to create a known-good reference for detecting post-push layer injection via manifest manipulation.

    `.github/workflows/layer-injection-guard.yml`:

    ```yaml
    name: Layer Injection Guard

    on:
      push:
        paths:
          - "Dockerfile*"
      schedule:
        - cron: "0 */6 * * *"

    jobs:
      build-and-sign:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4

          - name: Install tools
            run: |
              curl -sL https://github.com/google/go-containerregistry/releases/latest/download/go-containerregistry_Linux_x86_64.tar.gz \
                | tar xz crane
              sudo mv crane /usr/local/bin/
              curl -sL https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64 -o /usr/local/bin/cosign
              chmod +x /usr/local/bin/cosign

          - name: Build and push
            run: |
              docker build -t ${{ vars.REGISTRY }}/webapp:${{ github.sha }} .
              docker push ${{ vars.REGISTRY }}/webapp:${{ github.sha }}

          - name: Sign the image
            env:
              COSIGN_KEY: ${{ secrets.COSIGN_PRIVATE_KEY }}
              COSIGN_PASSWORD: ${{ secrets.COSIGN_PASSWORD }}
            run: |
              DIGEST=$(crane digest ${{ vars.REGISTRY }}/webapp:${{ github.sha }})
              cosign sign --key env://COSIGN_KEY ${{ vars.REGISTRY }}/webapp@$DIGEST

          - name: Record layer baseline
            run: |
              crane manifest ${{ vars.REGISTRY }}/webapp:${{ github.sha }} \
                | jq -r '.layers[].digest' > layer-baseline.txt
              echo "Layer count: $(wc -l < layer-baseline.txt)"

          - name: Upload baseline
            uses: actions/upload-artifact@v4
            with:
              name: layer-baseline
              path: layer-baseline.txt
    ```

    ---

    ### Image Secret Scanner (Multi-Stage Leak Detection)

    **Related lab:** <a href="../labs/tier-3/3.6-multistage-leaks/">Lab 3.6</a>

    Verifies `.dockerignore` excludes secret files, checks for `ENV`/`ARG` containing secret values, and runs Trivy secret scanning on the built image. Use this on every Dockerfile change.

    `.github/workflows/image-secret-scan.yml`:

    ```yaml
    name: Image Secret Scanner

    on:
      push:
        paths:
          - "Dockerfile*"
          - ".dockerignore"

    jobs:
      scan-secrets:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4

          - name: Verify .dockerignore exists
            run: |
              if [ ! -f .dockerignore ]; then
                echo "::error::.dockerignore is missing"
                exit 1
              fi
              for pattern in ".env" "*.key" "*.pem" "credentials"; do
                if ! grep -q "$pattern" .dockerignore; then
                  echo "::warning::.dockerignore does not exclude '$pattern'"
                fi
              done

          - name: Check for ENV/ARG secret patterns
            run: |
              if grep -iE '^(ENV|ARG)\s+.*(KEY|TOKEN|PASSWORD|SECRET|CREDENTIAL)' Dockerfile; then
                echo "::error::Dockerfile uses ENV/ARG for secret values. Use --mount=type=secret instead."
                exit 1
              fi

          - name: Build image
            run: DOCKER_BUILDKIT=1 docker build -t scan-target:latest .

          - name: Scan for secrets with Trivy
            uses: aquasecurity/trivy-action@master
            with:
              image-ref: scan-target:latest
              scanners: secret
              severity: CRITICAL,HIGH
              exit-code: 1
    ```

---

???+ abstract "Artifact Integrity"

    Workflows for SBOM generation, signing, attestation verification, and SLSA provenance. Ensures artifacts are complete, signed, and traceable to a specific CI build.

    ### SBOM Generation and Cross-Validation

    **Related labs:** <a href="../labs/tier-4/4.1-sbom-contents/">Lab 4.1</a>, <a href="../labs/tier-4/4.2-sbom-gaps/">Lab 4.2</a>

    Generates an SBOM with syft, then cross-validates against a grype vulnerability scan to find components the SBOM missed. Use this on every image build to catch SBOM coverage gaps.

    `.github/workflows/sbom-validation.yml`:

    ```yaml
    name: SBOM Generation and Validation

    on:
      push:
        paths:
          - "Dockerfile*"
          - "requirements*.txt"
          - "package.json"

    jobs:
      sbom:
        runs-on: ubuntu-latest
        env:
          IMAGE: ${{ vars.REGISTRY }}/app:${{ github.sha }}
        steps:
          - uses: actions/checkout@v4

          - name: Build image
            run: docker build -t $IMAGE .

          - name: Generate SBOM with syft
            run: |
              curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
              syft $IMAGE -o cyclonedx-json > sbom.json
              COMPONENT_COUNT=$(jq '.components | length' sbom.json)
              echo "SBOM contains $COMPONENT_COUNT components"

          - name: Cross-validate SBOM against vulnerability scan
            run: |
              curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
              grype $IMAGE --output json > scan-results.json
              SCAN_PKGS=$(jq -r '.matches[].artifact.name' scan-results.json | sort -u)
              MISSING=0
              for pkg in $SCAN_PKGS; do
                if ! jq -e ".components[] | select(.name == \"$pkg\")" sbom.json > /dev/null 2>&1; then
                  echo "::warning::Vulnerable component '$pkg' found by scanner but missing from SBOM"
                  MISSING=$((MISSING + 1))
                fi
              done
              if [ "$MISSING" -gt 0 ]; then
                echo "::warning::$MISSING vulnerable components missing from SBOM"
              fi

          - name: Check for vendored binaries not in SBOM
            run: |
              docker run --rm $IMAGE find /app -name "*.so" -o -name "*.a" 2>/dev/null | while read f; do
                LIBNAME=$(basename "$f" | sed 's/\.so.*//' | sed 's/^lib//')
                if ! jq -e ".components[] | select(.name | test(\"$LIBNAME\"; \"i\"))" sbom.json > /dev/null 2>&1; then
                  echo "::warning::Vendored binary $f not found in SBOM"
                fi
              done

          - name: Upload SBOM
            uses: actions/upload-artifact@v4
            with:
              name: sbom
              path: sbom.json
    ```

    ---

    ### Cosign Signature Verification Gate

    **Related labs:** <a href="../labs/tier-4/4.3-signing-fundamentals/">Lab 4.3</a>, <a href="../labs/tier-4/4.5-signature-bypass/">Lab 4.5</a>

    Verifies image signatures using keyless (Sigstore OIDC) identity pinning before deployment. Catches unsigned images and signatures from untrusted identities. Use this as a pre-deploy gate.

    `.github/workflows/verify-signatures.yml`:

    ```yaml
    name: Verify Signatures Before Deploy

    on:
      workflow_dispatch:
        inputs:
          image:
            description: "Image to deploy (with digest)"
            required: true

    jobs:
      verify-and-deploy:
        runs-on: ubuntu-latest
        permissions:
          id-token: write
        steps:
          - name: Install cosign
            uses: sigstore/cosign-installer@v3

          - name: Verify signature (keyless, identity-pinned)
            run: |
              cosign verify \
                --certificate-identity="https://github.com/${{ github.repository }}/.github/workflows/build.yml@refs/heads/main" \
                --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
                ${{ inputs.image }}

          - name: Deploy (only if verification passed)
            run: |
              echo "Signature verified. Proceeding with deployment."
              kubectl set image deployment/app app=${{ inputs.image }}
    ```

    ---

    ### SLSA Provenance Generation

    **Related lab:** <a href="../labs/tier-4/4.4-attestation-slsa/">Lab 4.4</a>

    Generates SLSA Level 3 provenance for container images using the official SLSA GitHub generator. Add this as a job after your build job. Proves the image was built by your CI pipeline from a specific commit.

    `.github/workflows/slsa-provenance.yml`:

    ```yaml
    name: Build with SLSA Provenance

    on:
      push:
        branches: [main]

    jobs:
      build:
        runs-on: ubuntu-latest
        outputs:
          digest: ${{ steps.build.outputs.digest }}
        steps:
          - uses: actions/checkout@v4

          - name: Build and push image
            id: build
            run: |
              docker build -t ghcr.io/${{ github.repository }}:${{ github.sha }} .
              docker push ghcr.io/${{ github.repository }}:${{ github.sha }}
              DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' ghcr.io/${{ github.repository }}:${{ github.sha }} | cut -d@ -f2)
              echo "digest=$DIGEST" >> "$GITHUB_OUTPUT"

      provenance:
        needs: build
        permissions:
          actions: read
          id-token: write
          packages: write
        uses: slsa-framework/slsa-github-generator/.github/workflows/generator_container_slsa3.yml@v1.9.0
        with:
          image: ghcr.io/${{ github.repository }}
          digest: ${{ needs.build.outputs.digest }}
          registry-username: ${{ github.actor }}
        secrets:
          registry-password: ${{ secrets.GITHUB_TOKEN }}
    ```

    ---

    ### Attestation Verification Gate (OIDC + SLSA)

    **Related lab:** <a href="../labs/tier-4/4.6-attestation-forgery/">Lab 4.6</a>

    Verifies that attestations were signed by the expected OIDC identity and validates SLSA provenance against the expected builder and source repository. Catches forged attestations created outside your CI system.

    `.github/workflows/attestation-verify.yml`:

    ```yaml
    name: Attestation Verification Gate

    on:
      workflow_dispatch:
        inputs:
          image:
            description: "Image reference to verify"
            required: true

    jobs:
      verify-attestation:
        runs-on: ubuntu-latest
        steps:
          - name: Install tools
            uses: sigstore/cosign-installer@v3

          - name: Verify attestation with OIDC identity
            env:
              IMAGE: ${{ inputs.image }}
            run: |
              cosign verify-attestation \
                --certificate-oidc-issuer https://token.actions.githubusercontent.com \
                --certificate-identity-regexp "https://github.com/${{ github.repository_owner }}/" \
                --type slsaprovenance \
                "$IMAGE"

          - name: Verify SLSA provenance
            env:
              IMAGE: ${{ inputs.image }}
            run: |
              curl -sSfL https://github.com/slsa-framework/slsa-verifier/releases/latest/download/slsa-verifier-linux-amd64 \
                -o /usr/local/bin/slsa-verifier && chmod +x /usr/local/bin/slsa-verifier
              slsa-verifier verify-image "$IMAGE" \
                --source-uri "github.com/${{ github.repository }}" \
                --builder-id "https://github.com/slsa-framework/slsa-github-generator/.github/workflows/generator_container_slsa3.yml"
    ```

    ---

    ### SBOM Tamper Detection (Sign + Cross-Validate)

    **Related lab:** <a href="../labs/tier-4/4.7-sbom-tampering/">Lab 4.7</a>

    Generates the SBOM, signs it as a cosign attestation, and cross-validates against a live vulnerability scan. Catches both post-generation tampering (via signature verification) and incomplete generation (via cross-validation).

    `.github/workflows/sbom-integrity.yml`:

    ```yaml
    name: SBOM Integrity Pipeline

    on:
      push:
        branches: [main]
        paths:
          - "Dockerfile*"
          - "requirements*.txt"
          - "package.json"

    jobs:
      sbom-sign-validate:
        runs-on: ubuntu-latest
        permissions:
          id-token: write
          packages: write
        env:
          IMAGE: ghcr.io/${{ github.repository }}:${{ github.sha }}
        steps:
          - uses: actions/checkout@v4
          - uses: sigstore/cosign-installer@v3

          - name: Build and push image
            run: |
              docker build -t $IMAGE .
              docker push $IMAGE

          - name: Generate SBOM from built image
            run: |
              curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
              syft $IMAGE -o cyclonedx-json > sbom.json

          - name: Sign and attach SBOM as attestation
            run: cosign attest --predicate sbom.json --type cyclonedx $IMAGE

          - name: Cross-validate SBOM against vulnerability scan
            run: |
              curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
              grype $IMAGE --output json > scan-results.json
              SCAN_PKGS=$(jq -r '.matches[].artifact.name' scan-results.json | sort -u)
              for pkg in $SCAN_PKGS; do
                if ! jq -e ".components[] | select(.name == \"$pkg\")" sbom.json > /dev/null 2>&1; then
                  echo "::error::Vulnerable component '$pkg' found by scanner but missing from SBOM"
                fi
              done
    ```

---

???+ abstract "IaC Security"

    Workflows for infrastructure-as-code supply chain attacks: Helm chart validation, Terraform module security, Ansible role scanning, and admission controller policy testing.

    ### Helm Chart Dependency Check

    **Related lab:** <a href="../labs/tier-5/5.1-helm-resolution/">Lab 5.1</a>

    Rejects version ranges in `Chart.yaml` and verifies `Chart.lock` exists with digests. Prevents Helm from resolving attacker-controlled higher versions. Use this on every repository that consumes Helm chart dependencies.

    `.github/workflows/helm-dep-check.yml`:

    ```yaml
    name: Helm Chart Dependency Check

    on:
      pull_request:
        paths:
          - "**/Chart.yaml"
          - "**/Chart.lock"

    jobs:
      check-helm-deps:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4

          - name: Reject version ranges in Chart.yaml
            run: |
              FOUND=0
              for f in $(find . -name "Chart.yaml" -not -path "*/charts/*"); do
                if grep -E 'version:\s*"[><=~^]' "$f"; then
                  echo "::error file=$f::Chart dependency uses version range. Pin to exact version."
                  FOUND=1
                fi
              done
              [ "$FOUND" -eq 0 ] || exit 1

          - name: Verify Chart.lock exists and has digests
            run: |
              for chart_yaml in $(find . -name "Chart.yaml" -not -path "*/charts/*"); do
                dir=$(dirname "$chart_yaml")
                if grep -q "dependencies:" "$chart_yaml"; then
                  if [ ! -f "$dir/Chart.lock" ]; then
                    echo "::error file=$chart_yaml::Chart has dependencies but no Chart.lock."
                    exit 1
                  fi
                fi
              done
    ```

    ---

    ### Helm Chart Security Scan (Hook Detection)

    **Related lab:** <a href="../labs/tier-5/5.2-helm-poisoning/">Lab 5.2</a>

    Renders Helm charts with `helm template` and scans for dangerous hooks: ClusterRoleBindings granting `cluster-admin`, and hooks running network commands. Use this before installing any chart.

    `.github/workflows/helm-security-scan.yml`:

    ```yaml
    name: Helm Chart Security Scan

    on:
      pull_request:
        paths:
          - "**/templates/**"
          - "**/Chart.yaml"

    jobs:
      scan-hooks:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - name: Install Helm
            uses: azure/setup-helm@v4

          - name: Scan for dangerous Helm hooks
            run: |
              FOUND=0
              for chart_dir in $(find . -name "Chart.yaml" -exec dirname {} \;); do
                RENDERED=$(helm template scan-check "$chart_dir" 2>/dev/null || true)
                if echo "$RENDERED" | grep -A10 'kind: ClusterRoleBinding' | grep -q 'cluster-admin'; then
                  echo "::error::CRITICAL: $chart_dir creates ClusterRoleBinding with cluster-admin"
                  FOUND=1
                fi
                if echo "$RENDERED" | grep -A30 'helm.sh/hook' | grep -qE '(curl|wget|nc |kubectl)'; then
                  echo "::error::CRITICAL: $chart_dir has hooks running network/kubectl commands"
                  FOUND=1
                fi
              done
              [ "$FOUND" -eq 0 ] || exit 1
    ```

    ---

    ### Terraform Module Security Check

    **Related lab:** <a href="../labs/tier-5/5.3-terraform-module-attacks/">Lab 5.3</a>

    Blocks `local-exec` provisioners in Terraform files and verifies `.terraform.lock.hcl` exists. Prevents arbitrary code execution via malicious modules. Use this on every repository with `.tf` files.

    `.github/workflows/terraform-security.yml`:

    ```yaml
    name: Terraform Module Security Check

    on:
      pull_request:
        paths:
          - "**/*.tf"
          - "**/.terraform.lock.hcl"

    jobs:
      scan-terraform:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4

          - name: Block local-exec provisioners
            run: |
              FOUND=0
              for f in $(find . -name "*.tf" -not -path "*/.terraform/*"); do
                if grep -q 'local-exec' "$f"; then
                  echo "::error file=$f::BLOCKED: Contains local-exec provisioner."
                  FOUND=1
                fi
              done
              [ "$FOUND" -eq 0 ] || exit 1

          - name: Verify lock file exists
            run: |
              for tf_dir in $(find . -name "*.tf" -exec dirname {} \; | sort -u); do
                if ls "$tf_dir"/*.tf 1>/dev/null 2>&1; then
                  if [ ! -f "$tf_dir/.terraform.lock.hcl" ]; then
                    echo "::error::$tf_dir has .tf files but no .terraform.lock.hcl"
                    exit 1
                  fi
                fi
              done
    ```

    ---

    ### Ansible Galaxy Role Security Check

    **Related lab:** <a href="../labs/tier-5/5.4-ansible-galaxy/">Lab 5.4</a>

    Verifies version pins in `requirements.yml` and scans role task files for dangerous patterns like SSH key planting, user creation, and sudoers modification. Use this on repositories that consume Ansible Galaxy roles.

    `.github/workflows/ansible-role-check.yml`:

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

    ---

    ### Admission Controller Policy Check

    **Related lab:** <a href="../labs/tier-5/5.5-admission-controller-bypass/">Lab 5.5</a>

    Tests OPA/Kyverno policies against Kubernetes manifests using conftest and verifies webhook `failurePolicy` is set to `Fail` (not `Ignore`). Use this to catch policy coverage gaps before deploying to a cluster.

    `.github/workflows/admission-policy-check.yml`:

    ```yaml
    name: Admission Controller Policy Check

    on:
      pull_request:
        paths:
          - "k8s/**"
          - "policies/**"

    jobs:
      test-policies:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4

          - name: Install conftest
            run: |
              wget -q https://github.com/open-policy-agent/conftest/releases/latest/download/conftest_Linux_x86_64.tar.gz
              tar xzf conftest_Linux_x86_64.tar.gz
              sudo mv conftest /usr/local/bin/

          - name: Test OPA policies against manifests
            run: conftest test k8s/ --policy policies/opa/ --all-namespaces

          - name: Verify webhook failurePolicy is Fail
            run: |
              for f in $(find . -name "*.yaml" -o -name "*.yml"); do
                if grep -q "ValidatingWebhookConfiguration\|MutatingWebhookConfiguration" "$f" 2>/dev/null; then
                  if grep -q "failurePolicy: Ignore" "$f"; then
                    echo "::error file=$f::failurePolicy: Ignore allows bypass. Use Fail."
                    exit 1
                  fi
                fi
              done
    ```

---

???+ abstract "Cloud Security"

    Workflows for cloud-native supply chain risks: marketplace image verification, serverless dependency scanning, IAM trust chain auditing, and cloud CI/CD role governance.

    ### Cloud Marketplace Image Verification

    **Related lab:** <a href="../labs/tier-9/9.1-cloud-marketplace-poisoning/">Lab 9.1</a>

    Validates that AMIs and VM images used in Terraform or CloudFormation come from approved publishers and checks for hardcoded SSH keys. Use this in any cloud environment that launches instances from marketplace images.

    `.github/workflows/marketplace-image-check.yml`:

    ```yaml
    name: Cloud Marketplace Image Verification

    on:
      pull_request:
        paths:
          - "**/*.tf"
          - "**/*.yaml"
          - "**/*.json"

    jobs:
      verify-images:
        runs-on: ubuntu-latest
        env:
          APPROVED_OWNERS: "099720109477,137112412989,679593333241"
        steps:
          - uses: actions/checkout@v4

          - name: Check AMI references in Terraform
            run: |
              FOUND=0
              for f in $(find . -name "*.tf" -not -path "*/.terraform/*"); do
                if grep -q 'ami-' "$f"; then
                  AMIS=$(grep -oE 'ami-[a-f0-9]+' "$f" | sort -u)
                  for ami in $AMIS; do
                    echo "Found AMI reference: $ami in $f"
                    echo "::warning file=$f::Verify AMI $ami comes from an approved publisher ($APPROVED_OWNERS)"
                  done
                fi
              done

          - name: Reject hardcoded SSH keys in cloud-init
            run: |
              FOUND=0
              for f in $(find . -name "*.tf" -o -name "*.yaml" -o -name "*.yml" | head -100); do
                if grep -qE 'ssh-rsa|ssh-ed25519|ecdsa-sha2' "$f" 2>/dev/null; then
                  echo "::error file=$f::Hardcoded SSH public key found. Use a key management service."
                  FOUND=1
                fi
              done
              [ "$FOUND" -eq 0 ] || exit 1

          - name: Check for approved base image policy
            run: |
              for f in $(find . -name "*.tf" -not -path "*/.terraform/*"); do
                if grep -q 'most_recent\s*=\s*true' "$f"; then
                  echo "::warning file=$f::AMI filter uses most_recent=true. Pin to a specific AMI ID."
                fi
              done
    ```

    ---

    ### Serverless Dependency Scanner

    **Related lab:** <a href="../labs/tier-9/9.2-serverless-supply-chain/">Lab 9.2</a>

    Audits Lambda/Cloud Function deployments for public registry usage, validates Lambda Layer ARNs against an allowlist, and checks for `sitecustomize.py` injection points. Use this on serverless projects to prevent layer poisoning.

    `.github/workflows/serverless-deps.yml`:

    ```yaml
    name: Serverless Dependency Scanner

    on:
      pull_request:
        paths:
          - "template.yaml"
          - "serverless.yml"
          - "**/*.tf"
          - "requirements*.txt"

    jobs:
      scan-serverless:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4

          - name: Check for public layer ARNs
            run: |
              FOUND=0
              for f in template.yaml serverless.yml $(find . -name "*.tf" -not -path "*/.terraform/*"); do
                [ -f "$f" ] || continue
                if grep -qE 'arn:aws:lambda:[^:]+:[0-9]+:layer:' "$f"; then
                  LAYERS=$(grep -oE 'arn:aws:lambda:[^:]+:[0-9]+:layer:[^"]+' "$f" | sort -u)
                  for layer in $LAYERS; do
                    ACCOUNT=$(echo "$layer" | cut -d: -f5)
                    if [ "$ACCOUNT" != "${{ vars.AWS_ACCOUNT_ID }}" ]; then
                      echo "::warning file=$f::External Lambda Layer: $layer"
                      FOUND=1
                    fi
                  done
                fi
              done
              if [ "$FOUND" -gt 0 ]; then
                echo "Review external layers. Only use layers from trusted accounts."
              fi

          - name: Verify no sitecustomize.py in layers
            run: |
              for layer_dir in $(find . -name "sitecustomize.py" 2>/dev/null); do
                echo "::error file=$layer_dir::sitecustomize.py found. This auto-executes on every Lambda invocation."
                exit 1
              done
              echo "PASS: No sitecustomize.py injection points found."

          - name: Check for VPC isolation
            run: |
              for f in template.yaml $(find . -name "*.tf" -not -path "*/.terraform/*"); do
                [ -f "$f" ] || continue
                if grep -q 'Runtime\|FunctionName\|aws_lambda_function' "$f"; then
                  if ! grep -q 'VpcConfig\|vpc_config\|subnet_ids' "$f"; then
                    echo "::warning file=$f::Lambda function has no VPC config. Consider VPC isolation to prevent exfiltration."
                  fi
                fi
              done
    ```

    ---

    ### IAM Trust Chain Auditor

    **Related lab:** <a href="../labs/tier-9/9.4-iam-chain-abuse/">Lab 9.4</a>

    Scans Terraform IAM resources for overly broad trust policies, wildcard AssumeRole permissions, and missing external ID conditions. Prevents transitive IAM chain exploitation. Use this on repositories managing AWS IAM.

    `.github/workflows/iam-chain-audit.yml`:

    ```yaml
    name: IAM Trust Chain Audit

    on:
      pull_request:
        paths:
          - "**/*.tf"
          - "iam/**"

    jobs:
      audit-iam:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4

          - name: Check for wildcard AssumeRole
            run: |
              FOUND=0
              for f in $(find . -name "*.tf" -not -path "*/.terraform/*"); do
                if grep -A10 'sts:AssumeRole' "$f" | grep -q '"Resource".*\*'; then
                  echo "::error file=$f::Wildcard AssumeRole permission. Restrict to specific role ARNs."
                  FOUND=1
                fi
              done
              [ "$FOUND" -eq 0 ] || exit 1

          - name: Check for missing external ID
            run: |
              for f in $(find . -name "*.tf" -not -path "*/.terraform/*"); do
                if grep -q 'assume_role_policy' "$f"; then
                  if grep -A20 'assume_role_policy' "$f" | grep -q 'sts:AssumeRole' && \
                     ! grep -A20 'assume_role_policy' "$f" | grep -q 'sts:ExternalId\|externalId\|external_id'; then
                    echo "::warning file=$f::Cross-account AssumeRole without ExternalId condition"
                  fi
                fi
              done

          - name: Check for overprivileged trust policies
            run: |
              for f in $(find . -name "*.tf" -not -path "*/.terraform/*"); do
                if grep -A30 'assume_role_policy' "$f" | grep -qE '"AWS".*:root'; then
                  echo "::warning file=$f::Trust policy allows entire account (:root). Restrict to specific roles/users."
                fi
              done

          - name: Recommend OIDC over long-lived credentials
            run: |
              for f in $(find . -name "*.tf" -not -path "*/.terraform/*"); do
                if grep -q 'aws_iam_access_key' "$f"; then
                  echo "::warning file=$f::Long-lived access key found. Use OIDC federation for CI/CD."
                fi
              done
    ```

---

## How to Use These Snippets

1. **Copy the YAML** into your `.github/workflows/` directory
2. **Customize** the trigger paths, environment variables, and allowlists for your project
3. **Combine** multiple workflows. Most teams need at least one from each category
4. **Test on a branch** before merging to `main`. Some snippets (e.g., hash verification) may fail on repos that have not yet adopted the practice

Each snippet is designed to be composable. Start with the ones that address your highest-risk attack surface, then layer in more as your security program matures.

## Further Reading

- [GitHub Actions Security Hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [SLSA Framework](https://slsa.dev/)
- [Sigstore Documentation](https://docs.sigstore.dev/)
- [OWASP Top 10 CI/CD Security Risks](https://owasp.org/www-project-top-10-ci-cd-security-risks/)
