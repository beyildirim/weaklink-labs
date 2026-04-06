# Lab 6.7: Case Study. Codecov Bash Uploader

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../analyze/" class="phase-step done">Analyze</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Lessons</span>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Eliminating curl | bash

**Goal:** Replace `curl | bash` with pinned, verified alternatives.

### Lesson 1: Pin scripts by hash

```bash
cat > /app/defenses/pinned-uploader.sh << 'SHELLEOF'
#!/bin/bash
EXPECTED_SHA="d6aa3207c4908d123bd8af62ec0538e3f2b9f257c3de62fad4e29cd3b59b41d9"
UPLOADER_URL="https://uploader.codecov.io/v0.1.0_5124/linux/codecov"

curl -fsSL "$UPLOADER_URL" -o /tmp/codecov
ACTUAL_SHA=$(sha256sum /tmp/codecov | awk '{print $1}')

if [ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]; then
    echo "ERROR: Codecov uploader hash mismatch!"
    echo "  Expected: $EXPECTED_SHA"
    echo "  Got:      $ACTUAL_SHA"
    exit 1
fi

chmod +x /tmp/codecov
/tmp/codecov upload
SHELLEOF
chmod +x /app/defenses/pinned-uploader.sh
```

### Lesson 2: Use GitHub Actions instead of scripts

```bash
cat > /app/defenses/workflow-after.yml << 'YMLEOF'
name: Tests with Coverage
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests with coverage
        run: pytest --cov=. --cov-report=xml
      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: coverage.xml
          fail_ci_if_error: true
YMLEOF
```

### Lesson 3: Restrict CI environment variable access

```bash
cat > /app/defenses/restricted-workflow.yml << 'YMLEOF'
name: Tests with Minimal Secrets
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: pytest --cov=.
      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: coverage.xml
YMLEOF
```

### Lesson 4: Audit all curl | bash patterns

```bash
/app/defenses/audit-curl-bash.sh
```

Scans all workflow files and shell scripts for `curl | bash` and `wget | bash` patterns. Any match requires immediate review and replacement with a pinned alternative.

### Verify understanding

```bash
weaklink verify 6.7
```
